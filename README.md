# Blog

Static site generator for blog optimized for long term stabilty: easily
hackable, specific to my needs (not configurable), minimal dependencies.

You likely wouldn't want to use this as is, but it might serve as inspiration
for your own version.

Deployed to [https://blog.xaviershay.com](https://blog.xaviershay.com)

## Usage

    bin/generate    # Build the website into `out` directory
    bin/serve       # Serve website at http://localhost:4001
    bin/test-local  # Run specs against local server (assumes already running)
    bin/test-remote # Run specs against production server
    bin/publish     # Publish website to S3/Cloudfront

Optional supporting tools:

* `aspell` for spell-checking.
* `ImageOptim` (OSX) or `Trimage` (Linux) for image optimization.

## History & Motivation

Previously I used Jekyll with a 3rd party theme. Over many years I accumulated
some frustrations:

* Backwards incompatible changes across Jekyll and dependencies frustrating to
  debug and upgrade (or pin to old version).
* Liquid templates were a novel syntax to relearn every time (and provided no
  value since my templates are not user-supplied).
* Layouts and partials and templates spread all over the place, hard to
  remember where something should be.
* Sprockets integration really opaque, and probably not even useful.
* Theme was not mobile responsive and did not have very accessible colors.
* Source and compiled files mixed together in source tree, confusing.
* Unclear what should be going in config or not.
* Unclear how to control compilation better to e.g. add in GZIP compression.

This led to the following design goals for this project:

* Support markdown with YAML metadata for posts. I've got an extensive back
  catalog of such posts, and like it fine as a composing format.
* Minimal dependencies, and stable ones where necessary.  I don't really have
  many feature needs. Optimize for maximum hackability with limited scope for
  breaking changes I don't control.
* AWS/Cloudfront as deployment target, with compressed assets.
* Does not need to be exactly compatible with current version of blog.
* Mobile friendly with accessible colors.
* Smoke tests to aid migration and ensure critical content was being rendered.
* At least as fast as Jekyll (~1s build time).

Other static site generators require familiarity with languages other than Ruby
and/or have reputations for similar backwards incompatible changes and/or bring
in a whole suite of transitive dependencies. (This is somewhat inevitable with
a growing user base.)

I identified the following as the "interesting" problems I needed to
solve:

* Converting markdown to HTML fragments.
* Assembling HTML fragments into full webpages.
* (Optional) Incremental compilation.

Those can mostly be solved neatly with the Ruby standard library, or old stable
gems. This project is an experiment in doing exactly that: **rolling my own
static site generator without using a framework.**

## Implementation

Post markdown and images are stored in `data`. All source files are stored by
type in `src/{ruby,erb,static}`.

Ruby is used to pre-process markdown files to extract YAML metadata and
transform it to support features like and index page and related posts.

Kramdown is used for converting markdown files into HTML snippets.

ERB is used as a templating language to embed that HTML into a full page.

Rake ties it all together and is used to support incremental builds,
definitions can be found in the standard `Rakefile`.

### Quirks

#### Incremental Builds

Each post technically depends on the index metadata (for possible yearly
archive links), but this relationship is not expressed in the build file as a
deliberate compromise.

Rake uses modification time to determine if a rebuild is necessary. A change of
any post triggers a rebuild of index metadata, which even if its content did
not change would then trigger a rebuild of all posts. For the primary case of
"editing a post" this effectively eliminated incremental builds and means a 1s
recompilation rather than a 0.1s one.

A fix for this would be to not trigger dependent tasks if file contents of an
intermediary artifact does not change (which I believe is how other build
systems like Buck work). I haven't figured out a neat way to either extend or
replace Rake to do this yet however.

A clean build is always used for production deployments to avoid any issues
this might cause.

#### GZIP'd assets

AWS serves gzip'd files by using AWS specific metadata. This is a problem for
local development since we need our own way of knowing which files are
compressed and serving up the appropriate headers. A custom WEBrick handler is
used for this purpose, see `src/ruby/server.rb`.

#### YAML Dates

As a somewhat arbitrary constraint, intermediary YML files are stored without
any "Ruby specific" metadata. This requires some conversion to/from `DateTime`
since YML doesn't support them natively (see
`src/ruby/support/load_markdown_from_file.rb`).

#### Web specs

Specs are written with what looks like Capybara, but to avoid a dependency and
exploit the fact that the site is static (so little benefit from viewing in a
headless browser) an extremely simple subset is reimplemented in
`spec/spec_helper.rb` using `nokogiri` and `net/http`.

As a bonus, it features easier to use failure messages that write the failing
source to a file for proper inspection.

#### Youtube Embeds

Youtube embeds aren't responsive and require some hacks to fix. Previously the
embed code was placed directly in markdown, which was a bit gross but also made
it hard to place the hacks.

There's no standard way to add custom markup to markdown.

Solution I've landed on is that Markdown is now post-processed (with a regex)
to replace a new custom tag `{{ YOUTUBE }}` with appropriate embed, with a
caption if provided.

## Dependencies

In addition to Ruby itself, the following standard library components are
critical dependencies:

* **ERB.** For templating HTML files.
* **Rake.** In particular for incremental build support.
* **Zlib.** For writing GZIP'ed files.

Outside of the standard library, we depend on the following gems:

* **Kramdown.** Pure ruby library to convert markdown to HTML. Transitive
  dependency on `rexml` which I consider standard library (it was extracted
  to a gem in Ruby 3).
* **WEBrick.** This used to be standard library but is now a gem. Extremely
  stable still though.
* **RSpec.** I'm ok with this, very stable. Might consider `Test::Unit`
  though if this was the only gem remaining.
* **Nokogiri.** Stable gem for HTML parsing for tests, no option in stdlib.

Other dependencies include:

* **AWS CLI.** For publishing the site to production.
* **Simple.css** Not a real dependency, it's vendored and used as a starting
  point rather than something I intend to upgrade.
* **Chart.css** Not a real dependency, it's vendored and used as a starting
  point rather than something I intend to upgrade.

## Wrong Turns

* **Pandoc.** I tried using pandoc instead of both Kramdown and ERB for
  compiling markdown and assembling pages. Doctemplates is too deficient as a
  templating language. In particular: no support for basic formatting filters
  (i.e. for dates), extremely limited support for things like checking if
  values are in arrays. Required extra scaffolding anyway to support index
  generation, and then layering in extra metadata to post generation (for
  things like recent/relevant posts) was going to require even more. Required a
  custom install on ubuntu for partial support (which I ultimately didn't use).
  Probably not that much more stable a dependency than `kramdown`.
* **Capybara.** Way overkill for what I needed, and required an extra
  dependency on webdriver. Replaced with ~50 lines of code for the subset I
  needed.
