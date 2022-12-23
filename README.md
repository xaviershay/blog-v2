# Blog

Static site generator for blog optimized for long term stabilty: easily
hackable, specific to my needs (not configurable), minimal dependencies.

You likely wouldn't want to use this as is, but it might serve as inspiration
for your own version.

Still WIP.

## Usage

    bin/generate    # Build the website into `out` directory
    bin/serve       # Serve website at http://localhost:4001
    bin/test-local  # Run specs against local server (assumes already running)
    bin/test-remote # Run specs against production server
    bin/publish     # Publish website to S3/Cloudfront

## Design Goals

* Support markdown with YAML metadata for posts. I've got an extensive back
  catalog of such posts, and like it fine as a composing format.
* Minimal dependencies, and stable ones where necessary. I've been burned by
  Jekyll upgrades in the past, Hugo has a bad reputation for backwards
  incompatability as well. I don't need that in my life. I don't really have
  many feature needs. Optimize for maximum hackability with limited scope for
  breaking changes I don't control.
* AWS/Cloudfront as deployment target, with compressed assets.
* Does not need to be exactly compatible with current version of blog.
* At least as fast as Jekyll (~1s build time). Currently slightly quicker for
  full build, much faster for incremental build.

## Implementation

Ruby is used to pre-process markdown files to extract YAML metadata and
transform it to support features like and index page and related posts.

Kramdown is used for converting markdown files into HTML snippets.

ERB is used to embed that HTML into a full page.

`Rake` ties it all together and is used to support incremental builds,
definitions can be found in the standard `Rakefile`.

AWS serves gzip'd files by using AWS specific metadata. This is a problem for
local development since we need our own way of knowing which files are
compressed and serving up the appropriate headers. A custom WEBrick handler is
used for this purpose, see `src/ruby/server.rb`.

### Quirks

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

## Wrong Turns

* **Pandoc.** Doctemplates is too deficient as a templating language. In
  particular: no support for basic formatting filters (i.e. for dates),
  extremely limited support for things like checking if values are in arrays.
  Required extra scaffolding anyway to support index generation, and then
  layering in extra metadata to post generation (for things like
  recent/relevant posts) was going to require even more. Probably not that much
  more stable a dependency than `kramdown`.
