# Blog

Pandoc based static site generator for blog.

Still WIP.

## Usage

    bin/generate    # Build the website into `out` directory
    bin/serve       # Serve website at http://localhost:4001
    bin/test-local  # Run specs against local server (assumes already running)
    bin/test-remote # Run specs against production server
    bin/publish     # TODO: Publish website to S3/Cloudfront

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

Pandoc is optimized for single files and doesn't appear to have a great way to
accumulate metadata from multiple files (e.g. to generate an index page). The
solve for this is a bit gross: a pre-processing step using Ruby to load all
files, extract YAML metadata, and aggregate and dump it out into standalone
files that can be used with pandoc. See `src/ruby/generate_index_metadata.rb`.

AWS serves gzip'd files by using AWS specific metadata. This is a problem for
local development since we need our own way of knowing which files are
compressed and serving up the appropriate headers. A custom WEBrick handler is used for this purpose, see `src/ruby/server.rb`.


`Rake` is used to support incremental build, defintions can be found in the
standard `Rakefile`.

## Dependencies

* **Ruby.** Building website has no further dependencies outside of the
  standard library. Testing requires bundler for a few gems.
  * **WEBrick.** This used to be standard library but is now a gem. Extremely
    stable still though.
  * **RSpec.** I'm ok with this, very stable. Might consider `Test::Unit`
    though if this was the only gem remaining.
  * **Nokogiri.** Stable gem for HTML parsing for tests, no option in stdlib.
* **Pandoc.** Primary mechanism for converting Markdown to HTML. Note for
  Ubuntu: as of 2022-12-20, apt has an older version of pandoc that doesn't
  support templates. You'll need to install it from [the
  website](https://pandoc.org/installing.html). Current development is done
  with 2.19.2.
