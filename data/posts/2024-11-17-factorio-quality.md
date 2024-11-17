---
layout: post
title: "Factorio Quality Math"
category: articles
tags: ['factorio']
description: Math
---

Factorio Space Age introduces a _quality_ mechanic. Using quality modules,
assemblers can get a chance to upgrade and items quality. From the
[wiki](https://wiki.factorio.com/Quality)

> When the machine produces an item, it performs a random roll with that chance
> to succeed. If it succeeds, the product is upgraded 1 level from its
> ingredients. If the product was upgraded, the machine repeats this process,
> now with a constant 10% chance of passing, rolling and upgrading until a roll
> fails.

Let's explore this mechanic with math!

Define $m$ to be a sequence representing the chance at each stage to upgrade to
a particular quality level. While Factorio caps quality at _legendary_ (4
upgrades), we do not need to encode that at this stage. Let $q$ be a sequence
of the _cumulative_ probability of generating a specific quality level or
higher. This examples uses 24.8% as the initial quality chance, representing
four legendary tier 3 quality modules.

$$
\begin{aligned}
m_n &= \begin{cases}
  0.248 &\text{, } n = 0\\
  0.1 &\text{, } n > 0 
\end{cases} \\
q_n &= \prod_{k=0}^{k \lt n}m_k
\end{aligned}
$$

Thus

$$
q = \{1, 0.248, 0.0248, 0.00248, ... \}
$$

Note that the 0th element represents the chance of getting an item of at least
base quality, i.e. 1. The chance of a legendary item (or higher) from a single
craft is $q_4$, or 0.0248%.

Making things more interesting, items can be recycled. This destroys the item
and returns 25% ($s = 0.25$) of the ingredients used to manufacture it. This suggests a
looping strategy for generating high quality items: for any item less than the
desired quality, recycle it and try again.

For initial simplicity, assume only one level of quality (uncommon). The
probability of generating an uncommon item from an initial craft, taking into
account recycling of non-upgraded items, can be expressed as a recursive
function:

$$
p_0 = q_1 + s (1 - q_1) p_0
$$

However, recyclers can themselves be fitted with quality modules, giving
another opportunity to upgrade the returned ingredients quality level. (Higher
level ingredients automatically craft higher level items.) Assume that the
recycler has the same configuration of quality modules as the assemblers.

$$
p_0 = q_1 + s (1 - q_1)\left[ q_1 + (q_0 - q_1) p_0 \right]
$$

Graphing these two functions, we see a marked increase in probability using a quality recycler:

TODO: GRAPH


Extending this model a step further to account for an extra quality level (rare):

$$
p_1 = q_2 + s(1 - q_2)[q_2 + \overbrace{(q_0 - q_1)p_1}^{\text{Base Recycle}} + \overbrace{(q_1 - q_2)p_0}^{\text{Uncommon Recycle}}]
$$

This suggests a generic definition:

$$
p_{n} = q_{n+1}+ s(1 - q_{n+1} )[q_{n+1} + \sum_{i=0}^{i\le n}(q_{i} - q_{i+1})p_{n-i}]
$$

Expanding for legendary quality ($n = 3$) results in:

$$
p_3 =
q_4 + s(1 - q_4)[q_4 +
(q_0-q_1)p_3 +
(q_1-q_2)p_2 +
(q_2-q_3)p_1 +
(q_3-q_4)p_0
]
$$

Graphing this shows the probability of crafting a legendary item at different quality levels.

TODO: graph

Inverting the function gives the expected number of initial crafts (i.e. sets of input items) needed per legendary item, which I feel gives a better intuition.


TODO: graph
