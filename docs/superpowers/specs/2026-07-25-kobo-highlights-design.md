# Kobo highlights fetch script

## Purpose

Download highlights for a given book from the user's Kobo cloud account, so
they can be manually reviewed and merged into `data/books/<slug>.md` (which
already stores highlights as `> quote` blockquotes, see
`data/books/a-man-called-ove.md`).

## Non-goals

- No automatic merge into the book's `.md` file. Output is a raw dump; the
  user copies quotes across by hand.
- No support for fetching all books at once. One title per run.
- No handling of Kobo's official public APIs — none expose highlights. This
  relies entirely on the unofficial `storeapi.kobo.com` endpoints used by the
  Kobo apps themselves. That surface is undocumented and can change or break
  without notice; this script has no long-term stability guarantee.

## Usage

```
bin/kobo-authorize          # one-time bootstrap, prints values to add to .env
bin/fetch-highlights "Private Citizens"
```

`bin/kobo-authorize` is modeled directly on the existing
`bin/strava-authorize`: run once, follow the printed instructions, paste
the resulting values into `.env`. `bin/fetch-highlights` then reads those
values via `dotenv` on every run.

**Correction from initial draft:** email/password auth was assumed
available (`KOBO_EMAIL`/`KOBO_PASSWORD` were added to `.env` before this
was verified). Research against a real reverse-engineered Kobo client
(`TnS-hun/kobo-book-downloader`, a working open-source DRM-removal tool
that authenticates against `storeapi.kobo.com`) shows Kobo's actual device
auth is a **browser-based device-activation flow**, not a password POST.
`KOBO_EMAIL`/`KOBO_PASSWORD` are not used by this design; `bin/kobo-authorize`
produces `KOBO_REFRESH_TOKEN`, `KOBO_USER_KEY`, `KOBO_DEVICE_ID`, and
`KOBO_SERIAL_NUMBER` instead, matching the persisted-value set that
reference client keeps.

## Architecture

Two Ruby scripts.

### `bin/kobo-authorize` (one-time bootstrap)

Mirrors `bin/strava-authorize`'s shape: generate credentials, print a URL
+ code, wait, print values for `.env`.

1. Generate `DeviceId` (64 random lowercase hex chars) and `SerialNumber`
   (32 random lowercase hex chars) — matches
   `kobo-book-downloader`'s `__GenerateRandomHexDigitString`.
2. `POST https://storeapi.kobo.com/v1/auth/device` with body
   `{AffiliateName: "Kobo", AppVersion: "4.38.23171", ClientKey:
   base64("00000000-0000-0000-0000-000000000373"), DeviceId, PlatformId:
   "00000000-0000-0000-0000-000000000373", SerialNumber}` → response has
   `AccessToken`, `RefreshToken`, `TokenType: "Bearer"`.
3. `GET https://auth.kobobooks.com/ActivateOnWeb` with query params
   `{pwspid: PlatformId, wsa: "Kobo", pwsdid: DeviceId, pwsav:
   AppVersion, pwsdm: PlatformId, pwspos: "Android", pwspov: "2.0"}` →
   HTML response. Extract the poll endpoint from
   `data-poll-endpoint="([^"]+)"` and the numeric activation code from
   `qrcodegenerator/generate.+?%26code%3D(\d+)`.
4. Print: "Open https://www.kobo.com/activate and enter `<code>`."
5. Poll: `POST` the poll endpoint URL repeatedly (every few seconds, with
   a timeout) until the JSON response has `"Status": "Complete"`. Its
   `RedirectUrl` field has `userId` and `userKey` as query params —
   extract both.
6. `POST /v1/auth/device` again, this time including `UserKey: userKey`
   in the body, to get an account-scoped `AccessToken`/`RefreshToken`.
7. Print `KOBO_REFRESH_TOKEN`, `KOBO_USER_KEY`, `KOBO_DEVICE_ID`,
   `KOBO_SERIAL_NUMBER` for the user to paste into `.env` (same UX as
   `strava-authorize` printing `STRAVA_REFRESH_TOKEN`).

Exact field names above are copied from working code in
`kobo-book-downloader`'s `Kobo.py` (`AuthenticateDevice`, `ActivateOnWeb`,
`WaitTillActivation`, `Login`), not guessed.

### `bin/fetch-highlights "<title>"`

1. **Refresh auth** — `POST /v1/auth/refresh` with `{AppVersion,
   ClientKey, PlatformId, RefreshToken: KOBO_REFRESH_TOKEN}` → fresh
   `AccessToken` for this run. (Reference client's refresh body doesn't
   need `DeviceId`, but this design sends the persisted `KOBO_DEVICE_ID`
   too since it costs nothing and hedges against that being wrong.)

2. **Discover endpoints** — `GET /v1/initialization` (bearer the access
   token) → response `Resources` map has a `library_sync` URL. Reference
   client fetches all its working endpoint URLs this way rather than
   hardcoding them, since Kobo's own apps do the same — hardcoding
   `library_sync`'s URL would be more fragile than discovering it fresh
   each run.

3. **Book lookup** — `GET` the `library_sync` URL (bearer the access
   token), paginating via the `x-kobo-synctoken` request header / response
   header pair (send token from previous page's `x-kobo-synctoken`
   response header; stop when response header `x-kobo-sync` is absent or
   not `"continue"`). Each page is a JSON array; entries of interest have
   shape `entry["NewEntitlement"]["BookMetadata"]["Title"]` and
   `entry["NewEntitlement"]["BookMetadata"]["RevisionId"]`. Fuzzy-match
   (case-insensitive substring) the `title` argument against `Title`
   across all pages. Multiple matches: print candidates, exit non-zero.
   Zero matches: print "not found", exit non-zero.

4. **Highlights fetch — unverified, spike required.** No public source
   (including `kobo-book-downloader` and `calibre-web`'s server-side
   reimplementation of this same sync protocol) documents a
   highlights/annotations endpoint. `calibre-web` only implements reading
   *position* sync (`CurrentBookmark`/`Statistics` under
   `/v1/library/<uuid>/state`), not highlight text. This design does not
   commit to a specific endpoint. Instead: try a short list of plausible
   candidate URLs built from the matched `RevisionId` (e.g.
   `/v1/library/<RevisionId>/annotations`,
   `/v1/user/annotations?entitlementId=<RevisionId>`,
   `/v1/library/<RevisionId>/bookmarks`), and for each, dump status code +
   raw body to `tmp/highlights/<slug>-spike-<n>.json` rather than parsing
   assumed fields. A human (the user) inspects these dumps to identify
   which one (if any) actually holds highlight text; final parsing logic
   is a follow-up increment once that's known, not part of this plan.

5. **Caching** — reuse the `cache(key, &block)` helper pattern from
   `bin/fetch-book`: raw HTTP responses written under `tmp/cache/`,
   replayed when `CACHE` env var is set.

6. **Output** — write whatever the spike step produces to
   `tmp/highlights/`, plus print a summary to stdout.

## Error handling

- Missing `KOBO_REFRESH_TOKEN`/`KOBO_USER_KEY`/`KOBO_DEVICE_ID`/
  `KOBO_SERIAL_NUMBER` → fail fast via `ENV.fetch`, same as `fetch-book`'s
  use of `ARGV.shift` and `strava-authorize`'s `ENV.fetch`. Message points
  at `bin/kobo-authorize`.
- Non-2xx auth or API responses → raise with the response code/body, no
  silent retries.
- Ambiguous/no title match → exit non-zero with a clear message (see step
  3 above), don't guess.
- Spike candidate requests that 404/error are expected, not failures —
  print status + short body snippet for each and move to the next
  candidate rather than raising.

## Testing

No automated test suite for this — matches existing `bin/*` scripts, which
are manually run, uncredentialed dev tools. Manual verification: run against
the user's real Kobo account for a known book (e.g. "Private Citizens") and
confirm the dumped JSON contains recognizable highlight text.
