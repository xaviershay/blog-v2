---
layout: post
title: "A System for Email"
category: articles
tags: ["other"]
image:
  feature: 'email.jpg'
  feature_credit:
    author: John Schnobrich
    title: Person Using Silver Laptop
    link: https://unsplash.com/photos/yFbyvpEGHFQ
---

For many years at Square, then later at Bradfield CS, I ran a class for new
hires and managers about managing email.  This is basically an _Inbox Zero_
approach, but I deliberately avoid the label because _Inbox Zero_ is a thing
people often misunderstand. It's not about how many emails you have.  My
mantra: I don't care what your system is, so long as you have one. Your inbox
should not be a source of stress.

I don't expect many to follow this process to the letter (I barely do...), but
it does a decent job of encouraging people to reflect on their own process and
come up with something that works better for them. For me these principles
scaled to a couple of hundred emails a day to my inbox, with many more filtered
out, without requiring too much dedicated effort.

Changing how you handle email, particularly in such a seemingly radical way can
be scary and require a lot of support and coaxing. Probably more than a blog
post can provide, but I'll do my best. If this seems scary to you, still at
least try it for a couple of days to see how you feel once you have the process
under your fingers.

This is really a collection of notes, rather than a considered way of
introducing the material. It also doesn't address instant messaging, nor
effective ways of actually writing email. If anyone wants to remix this
material (alternate presentation, videos, training for your team, whatever)
please feel free, it is unlikely I'm going to.

## Your inbox is for triage

Your inbox is not a to-do list. It is not a calendar. It is not a passive
information source. It is good for one thing and one thing only: triage. Triage
queues trend to zero, so when your inbox is empty you know you are done
processing. A previously unnoticed weight lifts off your shoulders, as the
nagging doubt that you're missing something important dissolves away.

### Buckets

Every email falls in to one of four buckets, each mapping to an action:

1. *No action.* There is nothing to do as a result of this email.
2. *Immediate action.* For tasks that take less than a minute, such as a quick
   reply. Do the task.
3. *Today.* Action needs to be taken in a timely manner, but will take too long
   to be part of the triage process. Add to your to-do list.
3. *Future.* No immediate action is required. Schedule something on your calendar.

After performing the associated action, you are done triaging that email, so
therefore it no longer belongs in your inbox. Archive it and move on to the
next one. This may make you uncomfortable for emails on your to-do list, since
you haven't done them yet but are removing them from your inbox. You won't
forget about them since they're written down on your to-do list, and you can
easily find them again using search (see below).

This *does not* imply that you respond to every email, which is a common
misunderstanding of this kind of process. Your inbox being empty means only
that you have seen everything that came in and decided what you are going to do
about it.

## Technique

To effectively triage email, you need to be able to move fast. Most emails
should take less than a second or two to handle.

[Enable keyboard shortcuts in
GMail.](https://support.google.com/mail/answer/6594?hl=en) There is only one
shortcut you absolutely have to know: <code>shift+{</code>. This will archive
the current message, and move to the next one in your inbox.

Open the first email in your inbox. Don't pick and choose! Open the first one.
Which bucket does it fall into? Do nothing, reply, add to your to-do list, or
add to your calendar. Now press <code>shift+{</code>, and the next message
appears. Rinse and repeat. With practice, you will be able to do this very
quickly. If you are doing this for the first time, after you have triaged back
a day or two, select all of the remaining messages and archive them. It's
probably not worth it to triage anything older than that, and there is a large
benefit to having your queue empty: you know when you're done and can close
your email client.

## To-do List

Your to-do list contains useful things you plan to do today. Things that might
be nice to do someday do not belong here. Put them on a different list. Your
to-do list must trend towards zero, otherwise you are committing to too much
work.

Each day, *start a new list.* I use a pen and paper, but you could use an
electronic list. Cross off everything that didn't get done yesterday. If it
is still worth doing, write it out again for today. Yes, this is redundant work!
By writing out your list each day, you ensure that your list doesn't get too
big, and nothing will be forgotten. You commit each day afresh to what you are
going to do. It makes it obvious which work empirically isn't getting done so
that you can explicitly handle that (de-commit, ask for help) rather than
giving the impression you forgot.

Everything on your list should be actionable. If a task hangs around for a few
days, maybe it isn't actionable enough? Can you break it down into smaller
chunks? Make it harder to procrastinate on? Set a calendar reminder next week
to follow up?

Keeping an effective to-do list is probably the most important technique in
this entire post.

## Passive Information Sources

Some types of emails — interesting or informational lists — are useful to keep
an eye on, but don't need to be part of the triage process. Have them skip your
inbox, then you can review at your leisure by searching for
<code>to:nameoflist@groups.google.com</code>. Alternatively, you can apply an
_Interesting_ label which acts as a saved search. Consider automatically
marking these emails as read, so you are not distracted by an _unread_ count in
your sidebar.

## Example

Alice emails a short status report. I fire off a quick clarification on one
point (bucket #2).

Bob is asking for feedback on a new proposal. I want to collect my thoughts, so
add an item to my to-do list: "Reply to Bob" (bucket #3). Later when I get to
this item, I can easily retrieve Bob's email by searching for
<code>from:bob</code>.

Charles sends an interesting looking article to a mailing list I'm on. Reading
a blog post takes longer than a minute, and is too distracting from triage, so
I open it in a background tab to scan when I am done with triage (bucket #3,
implicit to-do list). After triage (there are no emails left in my inbox), on
scanning the article it is really long but seems interesting, so I add it to my
proper to-do list. Tomorrow when creating my to-do list, I notice I never got
around to reading the article (as I'm crossing it out) and feel like I'm
probably too busy, so don't bring it forward.

I receive some alerts for a service my team operates, but I already know our
oncall is taking care of it so I skip it (bucket #1). I already filter the
general oncall list to *Skip Inbox* when I am not oncall (passive information
source).

A friend replies confirming a new lunch time for later in the week, I ensure it
is in my calendar (bucket #4).

Having no further emails in my inbox, I close my email client and turn to my
to-do list. I am confident it is a complete list of the tasks I need to
prioritize.

## Common mistakes

### Categories/Hierarchies

Explicitly categorizing email — usually by manually applying labels — adds too
much cognitive overhead to the triage, and provides negligible benefit. Search
is good enough that you will always be able to find what you are looking for
without a predefined taxonomy. (Though a taxonomy doesn't generally help you
find emails anyway...)

### Priority Inbox

GMail's priority inbox tries to do some of the triage work for you, but it
provides no benefit if you are triaging properly. Triage is fast and always
trends to zero, there is no need for a "triage this first" concept.

### Preemptive Filtering

Filters should only be created as a reaction to repeated triage. When you
notice yourself triaging the same class of email with a repeatable action, that
is the time to create a filter to automate that action.

* *Filter to trash.* My favorite. Some email just doesn't need to be read.
* *Skip inbox.* Useful for passive information sources.

Do not use filters to solely apply labels unless it helps you triage faster.

The first step I do with people when training in this method is have them
delete all of their filters. They can contribute to a sense of "not being on
top of everything" and rebuilding them from scratch using the above principle
(response to repeated triage) is the best way to address.

### Leaving to-do items in your inbox

It is tempting to leave email that you need to reference or reply to in your
inbox. Don't. It clutters your space, and clutters your mind. Search is a much
more efficient way of bringing back email. See the example above for how to do
this.

### Continuous triage

Don't keep your email open. Triage, then close it. Set an expectation that if
someone needs your attention urgently, they should call you.

Nothing should notify you when an email arrives. Triage on your terms.  Triage
is busy work and isn't the useful thing you should be doing. I'll usually
triage a couple of times a day, or more if I have a couple of minutes between
meetings and no one to talk to.

Don't triage email outside of work hours. Don't put work email on your personal
phone that might tempt you to check it.

## Bonus Techniques

### Follow up label

If you need to follow up on a lot of email that you send, it can be too much
overhead to add all of them to your to-do list or calendar. Instead, keep a
"followup" label separate from your inbox that you can scan once a day.
Keeping these in your inbox means you have to "re-triage" them every time,
which is wasted effort.

### Skip email

For tasks you are going to do either do immediately post-triage or add to your
to-do list you can skip over them without archiving (keyboard shortcut
<code>j</code>), then do a second pass. It is equivalent to using your inbox as
a hyper-short-term to-do list. This is a dangerous technique if you are not
already adept at clearing your inbox to zero, since by divorcing bucketing and
action it subtly encourages you to be sloppy in your categorization and clean
up.

## Putting it together

Try this system for a week. Don't cheat. This should be enough time to cement
the process into your subconscious. If you don't feel like you can function
without your inbox being regularly empty, you've made it. Now is the time to
cheat, cut corners, or optimize for your personality. Good luck!
