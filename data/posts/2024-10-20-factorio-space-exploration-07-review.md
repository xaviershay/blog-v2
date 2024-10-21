---
layout: post
title: "Factorio Space Exploration 0.6 Review"
category: articles
tags: ['factorio']
description: A second review of the Space Exploration mod for Factorio.
image:
  feature: 'se07/space-astro.jpg'
---


I last played [Space Exploration in 2021.](https://blog.xaviershay.com/articles/factorio-space-exploration-review.html) It’s an epic overhaul mod for [Factorio.](https://factorio.com/) Since then version 0.6 was released, including new science chains and space elevators! I also wanted to attempt an alternate victory. Spent about 250 hours working towards it before abandoning. Still got through the vast majority of the mod’s content again though, and it just keeps getting better.

All alternate victory content has been moved to the end and hidden by default to avoid undesired spoilers.

I created an [interactive mapshot](https://mapshot.xaviershay.com/se2-norbit/index.html) of the base for posterity. View different surfaces using the selector in the top right. Notable bases include:

* Nauvis (Main base)
* Nauvis Orbit (Space base)
* Ran (Initial cryonite and beryllium outpost, later plastic)
* Aestas (Initial vulcanite and iridium outpost)
* Kaliphos (Vitamelange outpost)
* Alastor (Beryllium outpost)
* Holmera (Holmium outpost)
* Hagen (Cryonite outpost)
* Caldius orbit (Nauvis sun power generation)
* Stardust (Naquium asteroid field)
* Skadi (Late-game beryllium outpost)
* Clausitry (Late-game iridium outpost)

## Approach

I had a few different intentions for this run beside simply the alternate ending.

My bus layouts have always been a bit janky, and I wanted to try one with a bit more structure using a “four corners” approach. The bus ran from the centre rightwards. Top right was reserved for science production, bottom right for a mall. I left enough room for about 3 groups of 4 belts, with some “science belts” placed above science production. Bottom left was for smelting, and top left was for labs and delivery of raw materials. This worked reasonably well through mid-game, though top left eventually didn’t have enough space for trains and I also moved smelting off-site. No obvious spot for oil processing.

<figure>
  <img src="/images/se07/bus.jpg" alt="Bus map" />
  <figcaption>Late game base. Science lanes, labs, and much of the smelter since removed.</figcaption>
</figure>

I skipped core mining last run, so was determined to try it. While I did set up a processing facility on Nauvis, ultimately throughput simply wasn’t comparable to setting up mines, and so didn’t use elsewhere.

<figure>
  <img src="/images/se07/core-mining.jpg" alt="Core mining" />
</figure>

[Cybersyn](https://mods.factorio.com/mod/cybersyn) has been a permanent fixture in my runs for a while, but this time I started without it. Using only [Train Control Stations](https://mods.factorio.com/mod/Train_Control_Signals) to set up refuelling stations, I got most of the way into the mid-game but ultimately caved and re-added Cybersyn. It’s simply too helpful for multi-item stations.

Last time I had one giant interconnected space base. This time I wanted to build separate platforms connected by rail, as well as using the space elevator to ferry trains from the surface. This was fun! I built for ~20SPM.

<figure class='image-strip'>
  <img src="/images/se07/space-map.jpg" alt="Norbit map" />
  <img src="/images/se07/space-science.jpg" alt="Norbit map" />
  <img src="/images/se07/space-astro.jpg" alt="Norbit map" />
  <img src="/images/se07/space-material.jpg" alt="Norbit map" />
  <figcaption>From top-left: space base map, science production, astronomic catalogs, material catalogs.</figcaption>
</figure>

I never intended to avoid delivery cannons, but given how comfortable I’d gotten with cargo rockets previously I started using them from the beginning and never found the need to reach for cannons. [Compact Circuits](https://mods.factorio.com/mod/compaktcircuit) helped give some consistency and space saving to the extensive combinator system used to control them (based on [similar principles to last time.)](https://www.youtube.com/watch?v=8NBxaq9nbOU&ab_channel=XavierShay) Late game I set up two outposts (beryllium and iridium) using teleporters.

<figure>
  <img src="/images/se07/cargo-rockets.jpg" alt="Cargo rockets" />
  <figcaption>The cargo rocket battery to the east of the mall.</figcaption>
</figure>

Biters were never much of an issue. Efficiency modules in miners mostly kept them out of the pollution cloud. As such never needed a full wall, just laser outposts to deter expansions. The railgun from goodie box after first rocket launched helped quickly clear bases. First behemoth biter wasn’t until 122 hours. Eventually got a few space lasers set up on auto-glaives to attempt to clear the whole planet, though they didn’t quite get to finish the job.

My biggest tip for Space Exploration is liberal use of speakers. There are so many things that can go wrong, and designing robust systems correctly on the first try is near impossible, that extensive alarms help keep the factory running. Standard uses include:

* Every outpost had an alarm for low stocks of anything that was being imported. I always intended to set up conditions for auto-launching of mixed rockets, but it was so easy to use infrequent alarms as a prompt to check a rocket was sufficiently full (or fix it if not) and manually trigger a launch that I never did.
* Every byproduct had an alarm if its buffer filled up. This identified issues where they weren’t being consumed fast enough, but also allowed putting off creating sinks on initial set up.
* Spaceships had alarms for critical ship fuel, reactor fuel, and water levels.
* If I needed to wait for a spaceship to travel somewhere, I set a speaker to alarm when speed was zero.

I found myself wanting to be able to place space platforms by dragging a selection rather than blueprinting and couldn’t find a mod to support … so I built my own! I’ve been wanting to make a mod for years but never had an idea to match until now. Introducing [Floor Placer](https://mods.factorio.com/mod/floor-placer), a mod that lets you place floor and tile ghosts easily.

Spaceships didn’t arrive until much later in the playthrough. I avoided rocket fuel ships completely, relying on ion stream engines until very late game. With the exception of a nexus ship for DSS, I kept all ships under 1000 stress. A cute trick I liked was scaling the accumulator charge (via combinators) to set the top speed for each ship. If a ship was running low on power, this would slow the ship down - reducing power drain from both engines but also lasers and shields - until it could recover.

<figure class='image-strip'>
  <img src="/images/se07/ship-1.jpg" alt="Ship 1" />
  <img src="/images/se07/ship-2.jpg" alt="Ship 2" />
  <img src="/images/se07/ship-3.jpg" alt="Ship 3" />
  <img src="/images/se07/ship-4.jpg" alt="Ship 4" />
  <figcaption>From top-left: initial hauler, larger naquium hauler, MK2 naquium hauler (though no acid delivery), and personal transport.</figcaption>
</figure>

## Notable Mods

[Full mod list.](https://docs.google.com/spreadsheets/d/1381gD53l8_r2Ca5h7re8M7vQ-ySDl1-G049YFfWQZTQ/edit?gid=0#gid=0&fvid=1683189342)

* [Ghost Counter.](https://mods.factorio.com/mod/ghost-counter) Stamping and counting a blueprint in satellite mode gave a combinator with ingredients for the blueprint, which was fantastic for loading up rockets to e.g. set up new bases. Would love an option for ignoring current inventory when calculating needs, to avoid the need to be in satellite mode.
* [Factory Planner.](https://mods.factorio.com/mod/factoryplanner) Even though it has some bugs and doesn’t work with certain cyclic recipes, still used extensively to plan builds.
* [Factory Search](https://mods.factorio.com/mod/FactorySearch.) For both locating assemblers, but also to find ingredients lost in storage.
* [Production Analyst](https://mods.factorio.com/mod/production-analyst). Mostly used late game to understand what was driving consumption.
* [Picker Dollies](https://mods.factorio.com/mod/PickerDollies) and [Wire Shortcuts.](https://mods.factorio.com/mod/WireShortcuts) Raved about these in a previous review but they’re so good I need to mention them again. For shunting entities without picking them up, and circuit wires not needing inventory.
* [Filter Helper](https://mods.factorio.com/mod/FilterHelper) and [Paste Logistics Settings.](https://mods.factorio.com/mod/paste-logistic-settings) Two more small but invaluable quality of life mods.
* [Circuit HUD.](https://mods.factorio.com/mod/CircuitHUD-V2) Pined current storage amounts of key ingredients to HUD. I rolled my own rate calculator using combinators to display also, but ultimately [Tiny Production UI](https://mods.factorio.com/mod/tiny-production-ui) did the same thing but better. Was generally able to confirm that outposts hadn’t broken from the production rates.
* [Solar calculator.](https://mods.factorio.com/mod/solar-calc) I used solar to power early outposts and this saved me making my own spreadsheet.


## Alternate Victory

My ultimate goal with this run was to achieve the alternative victory condition, not really knowing anything about it. I didn’t get all the way. The alternate victory is deliberately fairly obscure. If you haven't explored yourself, I would recommend skipping this section!

<details>
  <summary>Spoiler</summary>
  <p>I’d found the stargate at the anomaly in my previous run, but didn’t know much more than that. Had a sense that pyramids would be relevant so made sure to screenshot each one I visited. Figured out that I’d need 8 dimensional anchors, which I used naq solar panels around 8 different suns to power. Built a 10GW reactor and a coolant delivery systems at the anomaly to turn it on. I also researched 15 levels of Long Range Star Mapping.</p>

  <p>Then I got stuck. I found a hint on reddit saying that there was a mini-game hidden in a non-pyramid ruin, but after a combined ~250 zone discoveries and well after I’d found all pyramids I’d only found an extra two ruins, neither of which was interesting.</p>

  <p>After asking for a hint on discord, I needed to generate the surface for a non-pyramid planet (with no marker flag) for the ruin to reveal itself. The game itself reduced to solving a couple of 3D equations, which I used AI to help write a ruby script to solve.</p>

  <p>I used AI to convert a screenshot of Long Range Star Mapping coordinates into a CSV and confirmed my suspicion they were unit vectors.</p>

  <p>But … now what? More hints needed.</p>

  <p>I was disappointed to discover that the combinator attachments on the stargate were red herrings and didn’t do anything. I completely missed that you could interact with the eight circles on the gate manually … which also led to each one needing an extra 10GW power (90GW total).</p>
</details>

At this point I got some spoilers for more of the puzzle and decided it wasn’t for me. Not the sort of problem I enjoy solving. (Not to mention there’s only a week before Space Age comes out…)

<figure>
  <img src="/images/se07/milestones.jpg" alt="Milestones" />
</figure>
