# Kobo Highlights Fetch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Two Ruby CLI scripts — `bin/kobo-authorize` (one-time browser-based
device activation) and `bin/fetch-highlights "<title>"` (auth refresh, book
lookup by title, and an exploratory dump of candidate highlights endpoints).

**Architecture:** Standalone `bin/` scripts following this repo's existing
pattern (`bin/fetch-book`, `bin/strava-authorize`) — `require 'bundler/setup'`,
top-level procedural code, no shared lib. `dotenv` loads `.env` for
persisted tokens. `http` gem (already a Gemfile dependency) for all HTTP
calls.

**Tech Stack:** Ruby, `http` gem, `dotenv`, no new dependencies.

## Global Constraints

- `PlatformId` = `"00000000-0000-0000-0000-000000000373"` (exact value,
  verified against working reference client).
- `AppVersion` = `"4.38.23171"`.
- `AffiliateName` = `"Kobo"`.
- `ClientKey` = Base64 of `PlatformId` (`Base64.strict_encode64(PlatformId)`).
- User-Agent for all `storeapi.kobo.com`/`auth.kobobooks.com` requests:
  `"Mozilla/5.0 (Linux; U; Android 2.0; en-us;) AppleWebKit/538.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/538.1 (Kobo Touch 0373/4.38.23171)"`.
- No automated tests for these scripts — matches existing `bin/*` convention
  (manual, credentialed dev tools, no spec coverage). Verification is
  running the script for real and inspecting output.
- Every step that hits a live network endpoint is verified by the plan's
  author (Xavier) running it against his real Kobo account — an agent
  executing this plan cannot self-verify network-dependent steps and must
  hand control back for that confirmation before moving on.

---

### Task 1: `bin/kobo-authorize` — device auth + browser activation

**Files:**
- Create: `bin/kobo-authorize`

**Interfaces:**
- Produces: a script that, run with no args, prints four lines of the form
  `KOBO_REFRESH_TOKEN=...`, `KOBO_USER_KEY=...`, `KOBO_DEVICE_ID=...`,
  `KOBO_SERIAL_NUMBER=...` for the user to paste into `.env`. Task 2 depends
  on those four `.env` keys existing.

- [ ] **Step 1: Write the script**

```ruby
#!/usr/bin/env ruby
# Bootstrap Kobo device credentials via browser-based activation.
# Usage: bin/kobo-authorize

require 'bundler/setup'
require 'http'
require 'json'
require 'securerandom'
require 'base64'
require 'cgi'

PLATFORM_ID   = "00000000-0000-0000-0000-000000000373"
APP_VERSION   = "4.38.23171"
AFFILIATE     = "Kobo"
CLIENT_KEY    = Base64.strict_encode64(PLATFORM_ID)
USER_AGENT    = "Mozilla/5.0 (Linux; U; Android 2.0; en-us;) AppleWebKit/538.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/538.1 (Kobo Touch 0373/4.38.23171)"
STORE_BASE    = "https://storeapi.kobo.com"
AUTH_BASE     = "https://auth.kobobooks.com"

def hex(length)
  SecureRandom.hex((length / 2.0).ceil)[0...length].downcase
end

device_id      = hex(64)
serial_number  = hex(32)

def authenticate_device(device_id, serial_number, user_key: nil)
  body = {
    "AffiliateName" => AFFILIATE,
    "AppVersion"    => APP_VERSION,
    "ClientKey"     => CLIENT_KEY,
    "DeviceId"      => device_id,
    "PlatformId"    => PLATFORM_ID,
    "SerialNumber"  => serial_number,
  }
  body["UserKey"] = user_key if user_key

  response = HTTP.headers("User-Agent" => USER_AGENT)
                 .post("#{STORE_BASE}/v1/auth/device", json: body)

  raise "Device auth failed: #{response.code} #{response.body}" unless response.code == 200

  JSON.parse(response.body.to_s)
end

puts "Requesting anonymous device token..."
initial = authenticate_device(device_id, serial_number)

params = {
  "pwspid" => PLATFORM_ID,
  "wsa"    => AFFILIATE,
  "pwsdid" => device_id,
  "pwsav"  => APP_VERSION,
  "pwsdm"  => PLATFORM_ID,
  "pwspos" => "Android",
  "pwspov" => "2.0",
}

activate_response = HTTP.headers("User-Agent" => USER_AGENT)
                         .get("#{AUTH_BASE}/ActivateOnWeb", params: params)
html = activate_response.body.to_s

poll_match = html.match(/data-poll-endpoint="([^"]+)"/)
code_match = html.match(%r{qrcodegenerator/generate.+?%26code%3D(\d+)})
raise "Could not find poll endpoint in ActivateOnWeb response" unless poll_match
raise "Could not find activation code in ActivateOnWeb response" unless code_match

poll_url = AUTH_BASE + CGI.unescapeHTML(poll_match[1])
code     = code_match[1]

puts ""
puts "Open https://www.kobo.com/activate and enter this code: #{code}"
puts "Waiting for activation (checking every 3s, 5 minute timeout)..."

user_id  = nil
user_key = nil
deadline = Time.now + 300

loop do
  raise "Timed out waiting for activation" if Time.now > deadline
  sleep 3

  poll_response = HTTP.headers("User-Agent" => USER_AGENT).post(poll_url)
  poll_body = JSON.parse(poll_response.body.to_s)

  if poll_body["Status"] == "Complete"
    redirect_uri = URI.parse(poll_body.fetch("RedirectUrl"))
    query = CGI.parse(redirect_uri.query.to_s)
    user_id  = query.fetch("userId").first
    user_key = query.fetch("userKey").first
    break
  end
end

puts "Activated for user #{user_id}. Finalizing account-scoped tokens..."
final = authenticate_device(device_id, serial_number, user_key: user_key)

puts ""
puts "Add these to .env:"
puts ""
puts "KOBO_REFRESH_TOKEN=#{final.fetch('RefreshToken')}"
puts "KOBO_USER_KEY=#{final.fetch('UserKey', user_key)}"
puts "KOBO_DEVICE_ID=#{device_id}"
puts "KOBO_SERIAL_NUMBER=#{serial_number}"
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x bin/kobo-authorize`

- [ ] **Step 3: Hand off for live verification**

This step cannot be self-verified by an agent — it requires a real
browser login on Xavier's Kobo account. Stop here and ask Xavier to run:

```
bin/kobo-authorize
```

Expected: prints an activation code, waits after Xavier opens
`https://www.kobo.com/activate` and enters it in a browser, then prints
four `KOBO_*` lines. If it raises before reaching the activation code
(e.g. `Device auth failed: ...`, or the poll/code regex fails to match),
that means the request shape or the `ActivateOnWeb` HTML structure has
drifted from the reference client this was ported from — report the exact
error back rather than guessing a fix.

- [ ] **Step 4: Add printed values to `.env`, remove the unused ones**

Xavier pastes the four `KOBO_*` lines into `.env`. Also remove the
`KOBO_EMAIL`/`KOBO_PASSWORD` lines already there — this design doesn't use
password auth (see spec correction).

- [ ] **Step 5: Commit**

```bash
git add bin/kobo-authorize
git commit -m "Add Kobo device-activation bootstrap script"
```

(`.env` itself is gitignored — nothing to commit there.)

---

### Task 2: `bin/fetch-highlights` — auth refresh + book lookup

**Files:**
- Create: `bin/fetch-highlights`

**Interfaces:**
- Consumes: `.env` keys `KOBO_REFRESH_TOKEN`, `KOBO_USER_KEY`,
  `KOBO_DEVICE_ID`, `KOBO_SERIAL_NUMBER` (produced by Task 1).
- Produces: a script taking one CLI arg (book title substring) that prints
  the matched book's `Title` and `RevisionId` to stdout, or exits non-zero
  with a clear message if zero or multiple matches. This is the foundation
  Task 3 appends to (Task 3 adds the highlights-endpoint spike using the
  `RevisionId` this task resolves).

- [ ] **Step 1: Write the script**

```ruby
#!/usr/bin/env ruby
# Fetch highlights for a book from the user's Kobo cloud library.
# Usage: bin/fetch-highlights "<title substring>"

require 'bundler/setup'
require 'http'
require 'json'
require 'dotenv/load'

PLATFORM_ID = "00000000-0000-0000-0000-000000000373"
APP_VERSION = "4.38.23171"
CLIENT_KEY  = Base64.strict_encode64(PLATFORM_ID)
USER_AGENT  = "Mozilla/5.0 (Linux; U; Android 2.0; en-us;) AppleWebKit/538.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/538.1 (Kobo Touch 0373/4.38.23171)"
STORE_BASE  = "https://storeapi.kobo.com"

require 'base64'

`mkdir -p tmp/cache tmp/highlights`

def cache(key, &block)
  filename = "tmp/cache/#{key.gsub(/[^a-zA-Z\d]/, '--')}"
  if ENV['CACHE'] && File.exist?(filename)
    Marshal.load(File.read(filename))
  else
    contents = block.call(key)
    File.write(filename, Marshal.dump(contents))
    contents
  end
end

title_query = ARGV.shift
raise "Usage: bin/fetch-highlights \"<title>\"" unless title_query

refresh_token = ENV.fetch('KOBO_REFRESH_TOKEN') { raise "KOBO_REFRESH_TOKEN missing - run bin/kobo-authorize" }
device_id     = ENV.fetch('KOBO_DEVICE_ID')     { raise "KOBO_DEVICE_ID missing - run bin/kobo-authorize" }

refresh_body = {
  "AppVersion" => APP_VERSION,
  "ClientKey"  => CLIENT_KEY,
  "PlatformId" => PLATFORM_ID,
  "RefreshToken" => refresh_token,
  "DeviceId" => device_id,
}

refresh_response = cache("auth-refresh-#{refresh_token[0..8]}") do
  HTTP.headers("User-Agent" => USER_AGENT)
      .post("#{STORE_BASE}/v1/auth/refresh", json: refresh_body)
      .body.to_s
end

refresh_data = JSON.parse(refresh_response)
access_token = refresh_data.fetch('AccessToken') { raise "No AccessToken in refresh response: #{refresh_response}" }

auth_headers = { "User-Agent" => USER_AGENT, "Authorization" => "Bearer #{access_token}" }

init_response = cache("initialization") do
  HTTP.headers(auth_headers).get("#{STORE_BASE}/v1/initialization").body.to_s
end
resources = JSON.parse(init_response).fetch('Resources')
library_sync_url = resources.fetch('library_sync')

def fetch_library_page(url, headers, sync_token)
  request_headers = headers.dup
  request_headers["x-kobo-synctoken"] = sync_token if sync_token && !sync_token.empty?

  response = HTTP.headers(request_headers).get(url)
  body = JSON.parse(response.body.to_s)

  next_token = ""
  if response.headers["x-kobo-sync"] == "continue"
    next_token = response.headers["x-kobo-synctoken"].to_s
  end

  [body, next_token]
end

matches = []
sync_token = ""
loop do
  page, sync_token = fetch_library_page(library_sync_url, auth_headers, sync_token)
  page.each do |entry|
    metadata = entry.dig("NewEntitlement", "BookMetadata")
    next unless metadata
    title = metadata["Title"]
    next unless title&.downcase&.include?(title_query.downcase)
    matches << { title: title, revision_id: metadata["RevisionId"] }
  end
  break if sync_token.empty?
end

if matches.empty?
  $stderr.puts "No book found matching \"#{title_query}\""
  exit 1
elsif matches.size > 1
  $stderr.puts "Multiple books match \"#{title_query}\":"
  matches.each { |m| $stderr.puts "  - #{m[:title]}" }
  $stderr.puts "Use a more specific title."
  exit 1
end

book = matches.first
puts "Matched: #{book[:title]} (RevisionId: #{book[:revision_id]})"
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x bin/fetch-highlights`

- [ ] **Step 3: Hand off for live verification**

Network-dependent, needs Task 1's `.env` values in place. Ask Xavier to
run:

```
bin/fetch-highlights "Private Citizens"
```

Expected: `Matched: Private Citizens (RevisionId: <some-uuid>)`. If it
raises on the refresh call, the `KOBO_REFRESH_TOKEN` may have expired
(re-run `bin/kobo-authorize`) or the refresh body shape has drifted.
If it can't find `library_sync` in `Resources`, print the full
`init_response` body to see what keys are actually present — the
reference client's key name may be stale.

- [ ] **Step 4: Commit**

```bash
git add bin/fetch-highlights
git commit -m "Add Kobo library lookup by title"
```

---

### Task 3: highlights-endpoint spike

**Files:**
- Modify: `bin/fetch-highlights` (append to the end, after the `book =
  matches.first` / match-print block from Task 2)

**Interfaces:**
- Consumes: `book[:revision_id]`, `auth_headers`, `cache` — all defined
  earlier in the same file by Task 2.
- Produces: files under `tmp/highlights/<slug>-spike-N.json`, for Xavier to
  inspect by hand. Nothing downstream in this plan consumes them
  programmatically — that's deliberate, see spec's "Highlights fetch —
  unverified, spike required."

- [ ] **Step 1: Append the spike code**

```ruby
slug = book[:title].downcase.gsub(/[^a-zA-Z\d]/, '-')
revision_id = book[:revision_id]

candidates = [
  "#{STORE_BASE}/v1/library/#{revision_id}/annotations",
  "#{STORE_BASE}/v1/user/annotations?entitlementId=#{revision_id}",
  "#{STORE_BASE}/v1/library/#{revision_id}/bookmarks",
]

candidates.each_with_index do |url, i|
  response = HTTP.headers(auth_headers).get(url)
  outfile = "tmp/highlights/#{slug}-spike-#{i}.json"
  File.write(outfile, response.body.to_s)
  puts "#{url} -> #{response.code}, saved to #{outfile}"
end

puts ""
puts "Inspect the files above to find which (if any) holds highlight text."
```

- [ ] **Step 2: Hand off for live verification**

Ask Xavier to re-run:

```
bin/fetch-highlights "Private Citizens"
```

Expected: three `<url> -> <code>, saved to ...` lines, plus three files
under `tmp/highlights/`. Every candidate returning 404 is a valid, useful
result — it means none of these three guesses are the real endpoint, and
that gets reported honestly rather than papered over. Whatever comes back
(200 with a real highlights payload, all 404s, or something in between)
gets reported back verbatim so the next planning increment — writing the
actual parsing/extraction logic — is grounded in real data instead of
another guess.

- [ ] **Step 3: Commit**

```bash
git add bin/fetch-highlights
git commit -m "Add exploratory highlights-endpoint spike"
```

---

## After this plan

Task 3's outcome determines the next step, which is out of scope for this
plan (per the spec, extraction logic is a follow-up increment once the
real endpoint/schema is known):

- **A candidate returned real highlight data:** short follow-up plan to
  replace the spike loop with a single call to that endpoint and parse the
  actual response fields into the `tmp/highlights/<slug>.json` output
  named in the spec.
- **All candidates 404 / no real endpoint found:** report back to Xavier
  with the raw spike output; next steps are either more candidate URLs to
  try, or falling back to the USB/`KoboReader.sqlite` approach floated and
  declined earlier in brainstorming.
