---
layout: post
title: "Delivering Results, or How To Run A Sprint"
category: articles
tags: ["other"]
---

_I wrote this blueprint for my eight or so teams circa 2017 while leading Payments Engineering at Square, to provide a "strong default." Not every team followed it exactly, but it gave us common ground to improve delivery across the group._

A sprint is the key unit of work for an engineering team. It represents a distinct commitment of business value from a team. This document outlines the best way I’ve found to run one. A good sprint process has the power to both motivate a team, solve most cross-functional communication issues, and provide a huge amount of value.

There are two types of business value a sprint delivers: shipping something, or reducing delivery risk. The latter can cover things such as spikes, planning, measuring, and research.

Focus on predictability — reliably completing sprints of business value — before throughput. Most teams do the reverse, and as a result end up busy and not working effectively as a team.

## Rituals

A sprint is typically 2 weeks long, though 1 is common and 3-4 is not unheard of. If you aren’t finding that you have enough time to complete any business value, your sprint might not be long enough. If your sprint lacks cohesion, it may be too long.

The following rituals, described below, repeat every sprint.

* Backlog Grooming
* Iteration Planning
* Standup
* Demo
* Retro

### Backlog Grooming (previous week)

*Who:* PM, EM, select ICs as needed.

*What:* Ensure that the backlog is prioritized and roughly estimated, with sufficient for at least 2 sprints worth of work. Decide on ideal theme and rough set of tasks for next sprint, based on priorities.

*Output:* Proposed sprint prepared in task board.

### Iteration Planning (morning of sprint start)

*Who:* Team

*What:* Validate the proposed sprint (Do we all agree on what tasks mean? Estimates? What are we going to demo?), adjusting as needed, then decide on how the team is best going to deliver the sprint. Who does what first? Discuss execution risks (scary task, PTO, oncall, etc…). Golden rule: not allowed to commit to more work (# tickets, velocity, however you measure) than was completed last sprint.

*Output:* short 1-pager containing

* Overall theme of the sprint. There may be some outliers or secondary goals. Include those too.
* What is the team going to demo at the end of the sprint? (i.e. “what are we doing this sprint?” but demo phrasing is deliberate)
* What are the biggest risks to the team missing that goal, and what are we doing to mitigate?

I recommend broadcasting this document widely, but at the very least to stakeholders.

### Standup (every day)

*Who:* Team

*What:* Answer the question “are we on track to hit our goal, and how should we adjust course if needed?” Do this by explicitly going through each item in-progress, any risky items that haven’t started, and by referring back to the risks identified in Iteration Planning. (Don’t have each person report in. Encourages a status update, rather than a collaborative effort to figure out how the sprint is going.)

*Output:* None, but each person in the standup should answer the previous question the same way by the time you’re finished.

### Demo (end of sprint)

*Who:* Team + Stakeholders + Peers

*What:* Show off created business value, as committed to at start of sprint. This will either be a something that has shipped, or a reduction in risk. Don't bother spending time on partially complete work.

* Get stakeholders in the room. They care about what you’re doing.
* Bring the hype. Why was this an excellent thing to be working on?
* Show, don’t tell. It’s a demo, not a speech.
* Keep it snappy. Set an alarm for 5 minutes per demo.
* Customer perspective. Why do they care?

*Output:* None, though for bonus points send notes or a recording for people who couldn’t attend. Show off your work!

### Retro (end of sprint)

*Who:* Team

*What:* Focused reflection on the sprint.

* Did we demo what we said we were going to? Why/why not?
* Do we want to change anything as a result?

*Output:* Document any agreed upon changes.

## Common Issues and Implications

By default, people will tend to work on their own projects. It’s easy to do and doesn’t require talking to people. Over the long run though, working by yourself tends to be both lonely and bad for business. You end up chipping away at the same thing day in day out, without any sense of progress. Nothing ever ships. You lose sight of the bigger picture. You don’t feel like you’re having much impact. Making commitments as a team is the antidote to this malaise. The team succeeds or fails together.

It takes more work to prepare and schedule tasks such that a sprint can be cohesive. It’s worth it.

Committing to a team like this requires trust. Trust that your work will be recognized, even if you’re not the “lead” on whatever the current focus is. Consistent feedback is necessary here, to ensure that model behavior (hustling to help the team) is recognized, and individualistic behavior (working on your own thing rather than the team priority) is discouraged.

Team commitments are easiest when the team is homogeneous in skills. This isn’t always the case, but teams should still strive to be all working in a similar area at the same time, and to reduce the number of parallel tasks. The shared context from working on the same thing leads to better outcomes, faster.

A team should always strive to meet its commitments. It should feel bad to miss a sprint goal or a demo. Assuming a normal amount of estimation variability, this implies that the sprint won’t contain all the work that the team does for the week, since there needs to be some slack in the schedule. This can be uncomfortable for teams, particularly since there are often strong cultural norms around being “busy.” This is why the golden rule (don't commit to more than you got done last sprint) is the golden rule: it creates structural pressure to not overcommit. Encourage people to use any slack time at their own discretion: doing some extra polish, learning, getting a head start on next week, spiking on a new idea, refactoring that bit of code that’s been annoying them, etc… This enables people to contribute creatively.

Following on from the above, most teams focus on throughput when they should instead be focused on predictability. Throughput will follow.

Demo should be a collective celebration and reset before the next sprint. It’s an organizational breath. This help prevents “endless march” feelings from setting in.

## Recommended Reading

* [Scrum and XP from the Trenches](https://www.infoq.com/minibooks/scrum-xp-from-the-trenches-2/)
* [Slack (the book)](https://www.amazon.com/dp/B004SOVC2Y/)
* [What Your Standup Reveals About Your Team](https://blog.bradfieldcs.com/what-your-standup-reveals-about-your-team-ccebfb3a0b0f)
