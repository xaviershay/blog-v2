---
title: Civilization VI Expansion Review
description: A summary of my games this year plus a review of the first three expansions.
tags: ['review']
image:
  feature: 'civ6/header.jpg'
---

[Civilization VI](https://civilization.com/en-AU/) is the latest in a line of
strategy games from Firaxis. I originally played III and VI in high school and
university. V never grabbed me, and VI saw a lot of play when it first came
out in 2016. This year I picked up the first three expansions (Rise & Fall,
Gathering Storm, and New Frontiers) for the first time, which also required
some re-learning of base mechanics.

## Game Analysis

I won a deity (hardest) game twice with each victory condition --- except score, that doesn't count --- across
a variety of map types and leader. I also participated in two [Game of the
Month (6oTM)](https://forums.civfanatics.com/forums/civ6-game-of-the-month.545/)
challenges, both of which I did full write ups of ([6oTM
143](https://docs.google.com/document/d/1_TNIxUOd-5SW2KDPLuEFyOpMf2y50vxQMmVqSrBPSs4/edit#heading=h.j388xhr3at0f)
and [6oTM
144](https://docs.google.com/document/d/1Q3U3SgBeurw1OYJ5h8OX27H4plQZ2WuPgdEWOOrgUXM/edit#heading=h.j388xhr3at0f)).

<figure>
  <img src="/images/civ6/hof.jpg" />
  <figcaption>My Hall of Fame.</figcaption>
</figure>

Civilization is a tough game to get good at because "in the moment"
feedback loops both distract from and distort the larger picture. In a
building heavy game it's easy to zoom through multiple turns quickly and miss
optimization opportunities, while in a unit heavy game the opposite can be true
--- each turn takes a long time and feels like you're making plenty of decisions,
but they might not matter.

With the Rise & Fall expansion you can export your era score timeline to JSON.
I tried graphing this across games but I didn't find it particularly insightful.
What I actually want is metrics like "cities built" or "science per turn" so I
can better compare across games. Era score generally showed when I "took
off" in a game, but that by itself wasn't particularly interesting. For
example, the top line in the graph (for Poundmaker) was a fantastic start, and I
converted it into my second earliest finish, but ... how? This graph doesn't
help me understand.

<figure>
  <img src="/images/civ6/stats.png" />
  <figcaption>Era score stats. Teddy is offset because I started in a later era. This wasn't as insightful as I'd hoped. <a href='https://github.com/xaviershay/sandbox/tree/main/civ6'>Code here.</a></figcaption>
</figure>

The best technique I found to improve was to keep a detailed turn by turn log
as I did for the 6oTM games (linked above). This didn't take as much extra time
as you might think, since I was taking the time to think anyway and typing the
thoughts out was pretty cheap. I identified plenty of low level tactical
mistakes, individually only costing a turn or two but that in aggregate could
shave tens of turns off victory. I was also able to better evaluate my
larger strategic decisions with a log of what I was thinking when.

Ultimately I'd like to develop better heuristics like "by turn 100 for X type
of victory I should have Y" but that would require a lot more play.

## Review

_This section originally posted as Twitter threads
[here](https://twitter.com/xshay/status/1604597390480064512) and
[here](https://twitter.com/xshay/status/1604959780258213889). I've edited them slightly since._

In aggregate these three expansions add a lot of new options and depth to the
base game. I recommend them.


### Victory Conditions

From worst to best, victory conditions stack ranked. A good condition 
rewards optimization with earlier finishes, while creating interesting choices
and trade offs.

0. **Score.** Shouldn't exist, you should just lose. I'm salty this is a banner in the hall of fame. (I have not achieved it.)
0. **Diplomatic.** Yawn. Fallback option when you mess up a culture win. Can't accelerate clock much waiting for congress, limited options to generate diplomatic points, but even so incremental improvements don't lead to incremental improvement. "Guess what AI is thinking of" is not fun.
0. **Science.** Could be fun but in practice leads to a single high production city spamming projects, particularly with Royal Society (builders can rush district projects). Makes culture and faith largely irrelevant.
0. **Religious.** What if we took Domination but reduced the number of units and overall strategic complexity? Still have kind of a soft spot for it though, don't know why.
0. **Domination.** A classic, with plenty of opportunity to accelerate. Late game can become a grind managing large armies and high numbers of cities.
0. **Culture.** Top spot despite being the most inscrutable of the lot. Really needs better in game metrics. Transition from culture to tourism interesting. Faith and science remain relevant. Monopolies create incentive for war to collect more resources. Wonders and great people relevant.
{: reversed="reversed"}

### Expansions

In which I review each major new feature or mechanic on the following scale:

👍
: Good. Adds interest and fun.

🤷
: Neutral. Could go either way, situational.

🙅‍♀️
: Bad. Annoying, irrelevant, lacking depth, or generally not adding fun.

#### Rise & Fall

* **👍 Great Ages.** Creates a reason to deviate from the otherwise optimal line, sometimes makes delaying the correct move. Interesting! Not knowing which events are worth how many points makes it much less interesting, need [a mod to make accessible.](https://steamcommunity.com/sharedfiles/filedetails/?id=1699006932)
* **👍 Loyalty.** Better than any previous similar mechanic (e.g. culture flipping), more predictable. Options to modify it feel shallow (governors, cards don't do much) but don't think it matters much, the core mechanic is sufficient and doesn't need to be complicated.
* **👍 Governors.** creates extra layer of strategy without being totally broken. Opening lines pretty fixed though (Pingala too strong). [Better Balanced Game mod rework](https://steamcommunity.com/sharedfiles/filedetails/?id=2312050357) probably a worthwhile improvement but I haven't played with it yet.
* **🙅‍♀️  Enhanced Alliances.** Meh. Only alliance type that feels impactful in niche circumstance is military +5 bonus. Feel like I'm probably under-weighting the level 2 & 3 bonuses, but the game is usually won by then anyway.
* **🙅‍♀️ Emergencies.** Don't add any interest, easy to accidentally bollocks up diplomacy. Relevant for diplomatic victories I guess, but per above I'm never playing for that.
* **🤷 Government Plaza.** I'm torn. Adds a necessary "win more" building for each strategy which is bad. Some are fun though --- free builder --- but some are tedious --- builder providing district production makes space victory even less fun than it already was. District bonuses are interesting.


#### Gathering Storm

* **🙅‍♀️  Climate Change.** Intellectually appreciate that they included it, but CO2 mechanic has nothing going for it. Never impacts gameplay choice. Sea level rise is mostly just annoying.
* **🤷 Environmental Effects.** Adds some interest and risk/reward of getting tile bonuses. Generally positive, though often frustrating in the moment.
* **👍  Consumable Resources & Power.** Love it. Much better than previous similar mechanics.
* **🙅‍♀️  World Congress.** Hate it and the associated diplomatic victory. "Guess what the computer is thinking of" not fun.
* **🙅‍♀️  Giant Death Robots.** Hate it. So much stronger than any other end game unit it removes all army variability. Takes up too much space in late game science tree. Not fun, recommend [disabling with a mod](https://steamcommunity.com/sharedfiles/filedetails/?id=1656509410).
* **🙅‍♀️  Rock Band.** Takes an already inscrutable victory condition, adds another confusing sub-mechanic, and add a huge amount of randomness. Very not fun, [disable with mod.](https://steamcommunity.com/sharedfiles/filedetails/?id=1706697901)

#### New Frontiers

* **👍 Monopolies & Corporations.** Broken but in a fun way. Makes culture victory in particular more interesting and fun.
* **🙅‍♀️ Apocalypse.** Randomly deletes cities in the end game. Not fun.
* **👍 Secret Societies.** Broken but in a fun way. Each society feels very different and provides new strategic options.
* **🤷 Dramatic Ages.** Haven't played yet, no opinion.
* **🤷 Heroes & Legends.** Broken in a fun-ish way, but don't like how it basically makes faith essential. Don't find myself enabling it very often.
* **🙅‍♀️ Zombie Defense.** Meh. They're just more annoying barbs and none of the new traps or whatnot seem impactful.
