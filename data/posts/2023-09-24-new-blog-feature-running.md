---
title: "New Blog Feature: Running"
description: New running feature added to blog.
---

I've added a new [Running](/running/) section to the site. (This is a few months old at this point, but wanted to see it running for a while before announcing.)

* Link out to my Strava.
* Yearly summaries for both vert and distance.
* Lifetime bests, with links to relevant activities.
* Daily/weekly distances.

All of this is kept up-to-date by a [Github
Action](https://github.com/xaviershay/blog-v2/blob/main/.github/workflows/update-running.yml)
both on push and nightly. It fetches from the Strava API, using a cache file on
S3 to enable only fetching of most recent activities. It also "double caches"
using Github caching --- this is somewhat redundant in production but does mean I can still
make use of the S3 cache when developing locally.

The current
implementation introduces a dependency on `strava-ruby-client` which in turn
pulls in a number of other dependencies. I'd like to remove this in the future,
given I'm only using a single REST API call. I've updated the [README documentation](https://github.com/xaviershay/blog-v2/blob/main/README.md#dependencies) accordingly.
