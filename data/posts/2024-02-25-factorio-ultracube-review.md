---
layout: post
title: "Factorio Freight Forwarding Review"
category: articles
tags: ['factorio']
description: A review of the Freight Forwarding mod for Factorio.
image:
  feature: 'ff/ff-header.jpg'
---

Ultracube is the most creative overhaul mod for Factorio I've played yet. You
start with a single item: the cube. You never get another one. This cube is
required as a catalyst for fundamental bulk production of energy and material.

This limitation means factories cannot be scaled in the traditional manner. It
all comes down to optimising "cube uptime" in shunting it between operations.

In addition, there are many unique challenges in the later game requiring a
decent amount of circuitry expertise (spoilers below). I found these really fun
but they were certainly more difficult that in any other mod I've tried. This
is a hard mod overall, though short for an overhaul: I completed it in just
under 30 hours.

I _loved_ the theme and flavour text. Joyful, irreverant, but internally
consistent and aided in understanding.

While many (all?) assets were reused from vanilla and [Krastorio
2](https://mods.factorio.com/mod/Krastorio2), they were used in very different
ways which made my factory feel even more unique. For example, fabricators
instead of assemblers, red belt from the outset, and the first "basic matter"
material using the plastic icon.

This mod is still under active development. I kept a list of "annoyances" while
playing but virtually all of them have been fixed by the time I write this so
not worth sharing. The main unfixable issue relates to not being able to load
bulk recipes while they still have output: this covered in the FAQ, and can be
worked around adequately with [Inventory
Sensor](https://mods.factorio.com/mod/Inventory%20Sensor), which I would
consider a required mod anyway: getting reasonable cube efficiency without it
would be unnecessarily painful. (The documentation for that mod is lacking: you
need to place it with the green/red terminals facing _away_ from the assembler
otherwise it won't work.)

Technologies were not revealed until researching the relevant science card, a
touch I really appreciated. I never knew what was coming next and it was always
a nice surprise. More mods should do this.

I used Alien Biomes but didn't check my map settings and generated a world with
no trees. Wood isn't needed in early game so didn't think anything of it, but
_is_ required to bootstrap something in the mid-game, which was too late to
restart. I console cheated the needed catalyst.

## Mods

* [Wire Shortcuts.](https://mods.factorio.com/mod/WireShortcuts) Circuit wires
  don't need to be crafted. Probably going to use this on all future runs,
  making circuit wires always felt like a chore.
* [Picker Dollies.](https://mods.factorio.com/mod/PickerDollies) Shunt entities
  without picking them up, keeping their wire connections. Invaluable in
  particular for combinators. Adopting for all future runs.

## Spoilers

Only read this section if you've already played it yourself! This mod really is
a treat to figure out on your own.

* I never really figured out a good way to use the alternative basic matter and
  component recipes unlocked with T3 phantom cubes. Have a nagging feeling I've
  missed something interesting. ([Not just me it seems.](https://mods.factorio.com/mod/Ultracube/discussion/65cfc05d372da65e017845f7)
* Seeing my first cube powered train zoom off was a genuine moment of
  unexpected delight.
* Qubit processing was my favourite puzzle. I was afraid it was going to be
  like arcospheres from [Space
  Exploration](https://mods.factorio.com/mod/space-exploration), but it was a
  completely different non-trivial combinator problem with none of the
  frustrations of arcospheres.
* The Cyclotron was confusing, it looks like it is unpowered. It does operate
  how the description text says though (80s delay), and I solved it with a
  timer circuit with I _think_ is the intended solution it just took me a while
  to realise I was supposed to build it myself. Fun little challenge once I
  realised.
* Uranium processing adds a new element but to me it still played exactly the
  same as vanilla so felt a bit like extra complexity for no new challenge.
* The final Ziggurat challenge was tough but ultimately rewarding. I needed a
  few tries to get it right. It's possible to fail hard here, ending in state
  where you can't reconstruct the cube. Would have liked some warning, since I
  don't think that's ever been the case in any other mod. I had to reload a
  couple of times. I was surprised when the victory screen popped up on
  success, but apparently that's changed in recent versions.
* The power generation option unlocked at T6 feels too late: I already had to
  scale up power massively (annoyingly) for the Ziggurat to get there ... and
  I've already been shown a victory screen. (This might be fixed in later
  versions? Not sure.)
* I never got to playing with the Mystery Furnace. Will need to go back in...

I created a [mapshot of the factory for
posterity,](https://mapshot.xaviershay.com/ff/index.html) where you can scroll
and zoom around. This is a fantastic mod that everyone should try.



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
pollution based attacks, and never saw any behemoths. This was as expected, the
mod documentation suggested biters would be on the easier side.
After using [Rampant](https://mods.factorio.com/mod/Rampant) on my [last
run](/articles/factorio-exotic-industries-review.html) I enjoyed the change up.

<figure>
  <img src='/images/ff/ff-base-1.jpg' />
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

* Regular trains were changed to use charged batteries, which discharge with
  use. With a stack size of 100 and trains having 3 stacks of fuel, this meant
  that each double headed train could buffer up to 600 batteries before
  stabilizing. (Being able to read fuel values out of a train would fix this
  and many other issues!)
* Packed containers had a stack size of 1, where as unpacked had a stack size
  of 10. This means you can't rely on "just fill the train" conditions. Not the
  biggest deal initially, just mostly immersion breaking. Once cargo ships came
  into the picture, and without cross-island circuit networks, there's no way
  to avoid large buffers or to tell exactly how many containers are in the
  system at anyone time. It made it effectively impossible to do shared depots
  in a reliable way ... but that's exactly what is encouraged both mechanically
  and aesthetically by cargo ships.

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
  <img src='/images/ff/ff-mini-train.jpg' />
  <figcaption>Mini-trains next to their larger counterpart.</figcaption>
</figure>

### Minor Issues

* Making long waterways has the same ergonomic issues that making long rails
  lines does, requiring either multiple back and forths or a stop-start pattern
  to place two-way routes with signals. This exacerbated early game by the
  excrutiatingly slow patrol boat. Unlocking hovercraft was a major quality of
  life improvement.
* Heavy combat aircraft should have a logistics slot so it can self refuel and
  rearm. [ed: this has since been fixed!] Also needed more ammo slots. In
  practice wasn't that useful for taking out more than a single base, except
  for loading up the grid with personal lasers which didn't feel that
  satisfying.
* Aircraft make a high whining sound. Which is realistic but also too
  aggressive to actually play with. I disabled environmental sounds as a
  result.
* Cargo aircraft has a tiny inventory, annoying and meant couldn't serve its
  purpose that well.
* Lava pools don't appear until after you research Titansteel. Aside from being
  immersion breaking, I wasted a large amount of scouting time as a result.
  [ed: mod author claims this shouldn't be the case, so likely an issue on my
  end.]
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
  <img src='/images/ff/ff-base-2.jpg' />
  <figcaption>Rocket fuel production at the remote titansteel facility.</figcaption>
</figure>

I created a [mapshot of the factory for
posterity,](https://mapshot.xaviershay.com/ff/index.html) where you can scroll
and zoom around. I overall enjoyed this mod, though would recommend sticking to
default recommendations for a shorter experience.


