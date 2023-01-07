---
title: "New Blog Features"
description: New features for this blog added in the last month.
---

Over the last month I've invested quite a number of hours into improving this
blog.

## Visible Changes

### Main Blog

* New theme based on [`Simple.css`.](https://simplecss.org/)
* Designed with mobile usage in mind.
* More consistent image formatting.
* Better Open Graph meta tag support.

### Books

I migrated all my books from Goodreads to a new [dedicated page.](/books/)
Added a few neat features:

* Overall reading statistics using [`Charts.css`,](https://chartscss.org/) also
  used for statistics on recommendation pages.
* Filter by genre.
* Filter by 4 or 5 stars.
* Links to recommendation posts where available.
* Support abandoning of books.
* Cover images from [Open Library.](https://openlibrary.org)

## Invisible Changes

I migrated from Jekyll to a homebrew static site generator. Read more about the technical details and justification in [the `README`.](https://github.com/xaviershay/blog-v2)

* Custom tags that can be used in markdown source files.
  * `x-youtube` to embed mobile responsive youtube videos.
  * `x-spoiler` to mark spoilers in book reviews.
  * `x-reading-graphs` to embed reading statistics for a year.
* A custom build script that supports fast incremental builds based on digests
  of dependencies. It also reports on time taken in a comprehensible way. Here
  is what a clean build looks like:

        Book Fragments: 655 in 641ms (1ms avg)
         Book Metadata: 655 in 201ms (0ms avg)
            Book Pages: 655 in 370ms (1ms avg)
           Directories: 9 in 0ms (0ms avg)
                 Index: 3 in 76ms (25ms avg)
          Index (Book): 3 in 369ms (123ms avg)
        Post Fragments: 53 in 271ms (5ms avg)
         Post Metadata: 53 in 26ms (0ms avg)
            Post Pages: 53 in 72ms (1ms avg)
               Sources: 718 in 14ms (0ms avg)
          Static Files: 5 in 3ms (1ms avg)
            Synthetics: 1 in 212ms (212ms avg)

              Prebuild: 122ms
          Walking Tree: 255ms
                 Tasks: 2256ms
              Overhead: 49ms

                 Total: 2683ms
     
    Where as a no change incremental build looks like:

         Directories: 9 in 0ms (0ms avg)
             Sources: 718 in 12ms (0ms avg)
          Synthetics: 1 in 48ms (48ms avg)

            Prebuild: 115ms
        Walking Tree: 266ms
               Tasks: 61ms
            Overhead: 55ms

               Total: 497ms

* Ability to add arbitrary credits to a post, in addition to the header image
  credits.
* Test coverage that can run against both local and production instances.
