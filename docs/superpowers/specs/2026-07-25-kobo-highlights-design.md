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
bin/fetch-highlights "Private Citizens"
```

Requires `KOBO_EMAIL` and `KOBO_PASSWORD` set (via `.env`, loaded with
`dotenv`, matching the pattern in `bin/strava-authorize`).

## Architecture

Single Ruby script, `bin/fetch-highlights`, following the shape of the
existing `bin/fetch-book`:

1. **Auth** — device + login flow against `storeapi.kobo.com`:
   - `POST /v1/auth/device` with a generated `DeviceId` and Kobo's known
     public `ClientKey`/`PlatformId` constants → returns an `AccessToken`
     and initial `UserKey`.
   - `POST /v1/auth/login` (bearer the access token) with `UserKey`,
     `KOBO_EMAIL`, `KOBO_PASSWORD` → returns a `UserKey` + tokens scoped to
     the account.
   - Exact request/response fields are reverse-engineered from public
     write-ups of the Kobo app's sync protocol; not officially documented.

2. **Book lookup** — call the library sync endpoint, which returns the
   user's full library (titles + entitlement/volume IDs). Fuzzy-match the
   `title` argument (case-insensitive substring, same style as the existing
   slug logic in `fetch-book`) against returned titles. Multiple matches:
   print candidates and exit non-zero, asking for a more specific title.
   Zero matches: same, with a "not found" message.

3. **Highlights fetch** — call the annotations/bookmarks endpoint for the
   matched entitlement ID. The precise route and response shape are not
   confirmed ahead of time — this is the part most likely to need
   adjustment once tested against a real account and library sync response.

4. **Caching** — reuse the `cache(key, &block)` helper pattern from
   `bin/fetch-book`: raw HTTP responses written under `tmp/cache/`, replayed
   when `CACHE` env var is set. Avoids repeatedly hitting the API while
   iterating on parsing logic.

5. **Output** — write the raw highlights JSON to
   `tmp/highlights/<slug>.json`, where `<slug>` is derived from the title
   the same way `fetch-book` derives it. Also print to stdout for quick
   inspection.

## Error handling

- Missing `KOBO_EMAIL`/`KOBO_PASSWORD` → fail fast via `ENV.fetch`, same as
  `fetch-book`'s use of `ARGV.shift` and `strava-authorize`'s `ENV.fetch`.
- Non-2xx auth or API responses → raise with the response code/body, no
  silent retries.
- Ambiguous/no title match → exit non-zero with a clear message (see step
  2 above), don't guess.

## Testing

No automated test suite for this — matches existing `bin/*` scripts, which
are manually run, uncredentialed dev tools. Manual verification: run against
the user's real Kobo account for a known book (e.g. "Private Citizens") and
confirm the dumped JSON contains recognizable highlight text.
