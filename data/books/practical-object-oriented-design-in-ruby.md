---
id: OL26007226M
slug: practical-object-oriented-design-in-ruby
title: Practical Object Oriented Design In Ruby
author: Sandi Metz
rating: 5
pages: 247
categories:
- non-fiction
reads:
- finished_at: '2014-05-24'
---
tl;dr you should read it if you're a programmer.

If you are new to OO, this is a really good introduction. Useful examples, not preachy, discusses pros and cons of different approaches.

If you are a veteran, this will give you concrete words to verbalize many things you already do, helping you to explain and teach others.

Things I particularly liked:

* Large number of examples, with specific explanations of each step.
* "The purpose of design is to lower costs." If design or testing isn't doing that, it isn't doing what it should be doing. For example, on Law of Demeter: "as a "law" it's more like 'floss your teeth every day' than gravity".
* Big focus on identifying things that change at different rates, and using that to influence your roles and public/private interfaces.
* "Concrete is simple to understand, but hard to extend. More abstraction is harder to understand, but easier to extend." Then tension between these two is important.
* Prefer template method over `super`, because it reduces dependency. (I hadn't considered doing this.)
* Discussion of inheritance vs composition, and when to use either. (In general use composition, but inheritance is a better choice for certain things.)
* The chapter on testing uses minitest with manual role verification. RSpec mocks can do this for you automatically*, but starting with doing it by hand is probably a better option so you can get a feel for what's going on under the hood.
* Throughout she is very conscious of different needs and abilities of junior vs senior programmers. For example, well written tests reduce costs, but this is not true for many beginner programmers - they spend more time writing too many of the wrong kinds of tests, which end up making the program harder to change. She recommends sticking with it, most people make it through that phase ;)

A number of people at work have read it on my recommendation, and have all made a point of thanking me for it.

