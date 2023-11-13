---
layout: post
title: "Factorio Freight Forwarding Review"
category: articles
tags: ['factorio']
description: A review of the Freight Forwarding mod for Factorio.
image:
  feature: 'ff/ff-header.png'
---

[Freight Forwarding](https://mods.factorio.com/mod/FreightForwarding) is a
small mod for [Factorio](https://www.factorio.com/)
that reduces stack sizes dramatically, but allows resources to be packed and
unpacked into containers for transport. It also provides new logistic options,
in particular cargo ships and associated island based play.

To increase complexity the author recommends adding [Tungsten](https://mods.factorio.com/mod/bztungsten), [Natural Gas](https://mods.factorio.com/mod/bzgas), and
[Noble Metals](https://mods.factorio.com/mod/bzgold) from the [BZ mods collection.](https://brevven.github.io/bz/) (It includes [Lead](https://mods.factorio.com/mod/bzlead) & [Titanium](https://mods.factorio.com/mod/bztitanium) by default).
In hindsight I probably didn't need quite so many additions: the extra
complexity exacerbated what otherwise would have been minor issues. The
logistics heart of the mod could have been enjoyed more fully with default
settings.

Launching an interstellar satellite to win the game took me about 55 hours.

Using default settings, biters were a non-issue. I triggered virtually no
pollution based attacks, and never saw any behemoths.

<figure>
  <img src='/images/ff/ff-base-1.png' />
  <figcaption>The heart of late science production.</figcaption>
</figure>

### Core Gameplay

For the full logistics experience, I avoided any train logistics mods (like [LTN](https://mods.factorio.com/mod/LogisticTrainNetwork)
or [Cybersyn](https://mods.factorio.com/mod/cybersyn)). You can get a long way with train stop limits these days, and it
also meant I could attempt to handle container return in the same train. This
was fun until it wasn't.

Item re-use shows up in two places in the mod: containers can be packed and
unpacked, and batteries can be charged and discharged. Both of these processes
had a failure rate built into them (1% initially), meaning that systems needed
to be continually topped up. I liked this idea but in practice it was
frustrating:

* Regular trains were changed to use charged batteries, which decharge with
  use. With a stack size of 100 and trains having 3 stacks of fuel, this meant
  that each double headed train could buffer up to 600 batteries before
  stabilizing. (Being able to read fuel values out of a train would fix this
  and many other issues!)
* Packed containers had a stack size of 1, where as unpacked had a stack size
  of 10. This means you can't rely on "just fill the train" conditions and
  instead need to rely on circuit conditions. Not the biggest deal initially,
  aside from finding it immersion breacking. Once cargo ships came into the
  picture, and without cross-island circuit networks, there's no way to avoid
  large buffers or tell exactly how many containers are in the system at anyone
  time. It made it effectively impossible to do shared depots in a reliable way
  ... but that's exactly what is encouraged (both mechanically and
  aesthetically) by cargo ships.

Ultimately this was frustrating enough to push me away from regular trains and
back to fuel loaded mini-trains. If I were to play this mod again I'd remove
the failure rates and reduce the empty container stack size to one to match
packed containers.

### Highlights

* [Mini-trains](https://mods.factorio.com/mod/Mini_Trains) are SO COOL. I love
  them.
* Also loved [cargo ships.](https://mods.factorio.com/mod/cargo-ships)
* Really enjoyed oil platforms. Having hard to access but then subsequently
  abundant oil was a fun gameplay change up.
* Final logistics challenges were hard (cobalt and titansteel), mostly due to extreme distance.
  Demoralised me for a bit, but was satisfying once done.
* Used [Factory Planner](https://mods.factorio.com/mod/factoryplanner) and
  [Factory Search](https://mods.factorio.com/mod/FactorySearch) for the first
  time. They are becoming standard in my QoL mods.

<figure>
  <img src='/images/ff/ff-mini-train.png' />
  <figcaption>Mini-trains next to their larger counterpart.</figcaption>
</figure>

### Minor Issues

* Making long waterways has the same ergonomic issues that making long rails
  lines does, requiring either multiple back and forths or a stop-start pattern
  to place two-way routes with signals. This exacerbated early game by the
  excrutiatingly slow patrol boat. Unlocking hovercraft was a major quality of
  life improvement.
* Heavy combat aircraft should have a logistics slot so it can self refuel and
  rearm. Also needed more ammo slots. In practice wasn't that useful for taking
  out more than a single base, except for loading up the grid with personal
  lasers which didn't feel that satisfying.
* Aircraft make a high whining sound. Which is realistic but also too
  aggressive to actually play with. I disabled environmental sounds as a
  result.
* Cargo aircraft has a tiny inventory, annoying and meant couldn't serve its
  purpose that well.
* Lava pools don't appear until after you research Titansteel. Aside from being
  immersion breaking, I wasted a large amount of scouting time as a result.
* Too much complexity in mall items such as assemblers (likely from adding too
  many BZ mods.) Discouraged early mall building, which combined with limited
  stack size led to more manual work.
* Even after massively upgrading cobalt production, it felt so rare that I
  didn't want to use it for anything except rocket launches, cutting off some
  end game tech like advanced solar and fancy batteries.

### Mistakes and opportunities (minor spoilers):

Mostly just notes and reflections to myself!

* Rich copper ore should be thought of as primarily a source of Noble Metals,
  with copper as a by-product. Ended with very lopsided production.
* Tried having a shared battery fueling setup for trains, but given the
  buffering issues it required a truly enormous number of batteries, and
  continually ended up lopsided. In the late game I switched back to fuel
  powered mini trains to avoid these issues.
* Didn't put big miners on titanium mines early enough, suffered through
  shortage much longer than needed.
* I never was able to consistently remember which color the chain and regular
  buoys were, and I oftened placed the wrong ones only to be discovered much
  later.
* One train per resource is a standard approach, but feel like this mod would
  really shine using mixed deliveries. Experience likely tarnished by how
  unreliable both fueling and container provisioning felt especially across
  multiple trains. Possibly needs either cross-island
  circuits and/or Cybersyn to really make it work.

<figure>
  <img src='/images/ff/ff-base-2.png' />
  <figcaption>Rocket fuel production at the remote titansteel facility.</figcaption>
</figure>

I created a [mapshot of the factory for
posterity,](https://mapshot.xaviershay.com/ff/index.html) where you can scroll
and zoom around. I overall enjoyed this mod, though would recommend sticking to
default recommendations for a shorter experience.


