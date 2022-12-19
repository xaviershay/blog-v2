---
layout: post
title: "Lessons From Lavabit"
category: articles
tags: ["law"]
---

Late last year, Lavabit's owner Ladar Levison was held in civil contempt for
failing to cooperate with FBI investigations into whistleblower [Edward
Snowden][snowden]. It was a bit of a mess on both sides, which emphasised to me
some important lessons.

[snowden]: https://en.wikipedia.org/wiki/Edward_Snowden

### Don't Be A Jerk

In operating a service predicated on privacy, Levison should have understood
his obligations to law enforcement. By serving a pen/trap order to Lavabit,
the FBI was lawfully authorized to monitor non-content metadata of Snowden's
emails such as to, from and timestamps. In pursuit of this the FBI was
authorized to install its own hardware network capture device, but as all
communication was all encrypted this was not useful without Lavabit's private
keys to decrypt it. Lavabit could have provided its own implementation of such
monitoring, though it did not have this capability at the time it was served.

Levison was uncooperative. He initially indicated he was not going to comply
with the order. After two weeks he was accused of contempt[^1] and being accused of contempt did he offer to
implement monitoring on behalf of the FBI. This offer appears to me an
obviously minimal effort that would not have met the requirements of the order.

[^1]: Technically, he was ordered to appear in court and "show cause" why he shouldn't be held in contempt.

For $2000 Levison would collect metadata and deliver it to the government
after the order's 60-day expiration period. It would take a "week to a week and
half" to implement.  This is clearly insufficient. The point of prospective
tracking is to obtain _current_ data about a person's communications.

For an extra $1500, Levison would provide daily updates. This is more useful,
but still not really what was asked. Further, both options seem extortive.
Assuming even a high consulting rate of $200/hour, I would expect a much faster
turn-around. It's not that hard to schedule an email of logs.

I cannot believe this was a good faith offer. The goverment rejected it, and
instead demanded Lavabit's private keys so it could operate its own hardware
monitoring device. The FBI tried multiple methods of obtainings these keys
above and beyond the original pen/trap order, including a search warrant and a
grand jury subpoena. It isn't clear whether this is legal, since no appelate
court has ruled on it.

After another two weeks and some back and forth, a deadline was set for
Lavabit to provide its keys. At the last possible moment, Levison furnished
them in "an 11-page printout containing largely illegible characters in 4-point
type". This was rightly rejected by the government, and a few days later they
successfully sought sanctions of $5000 per day until the keys were provided in
a sensible format.

Two days and $10,000 later, Lavabit complied, and also shut down their service.

### If You Are Going To Be A Jerk, Get A Lawyer

So that all may have been a masterful act of civil disobendience. Except a lack
of legal preparation rendered it expensive and largely ineffective. This resistance could have forced an
appelate court ruling on the legality of compelled key disclosure. Instead,
it was dismissed on a technicality. Since Lavabit
didn't raise most of its arguments until it got to appeal (by which time it had
support of
[ACLU](https://www.aclu.org/sites/default/files/assets/stamped_lavabit_amicus.pdf)
and [EFF](https://www.eff.org/document/lavabit-amicus) amicus briefs), it
waived its grounds for appeal.

Levison appeared without consul in many initial discussions and hearings, and
possibly did so illegally when representing Lavabit. The [appellate opinion](http://scholar.google.com/scholar_case?&case=3757852381066827830)
noted in a footnote:

> As a limited liability company, Lavabit likely should not have been permitted
> to proceed pro se at all.

That ["it took a week for me to identify an attorney who could adequately
represent [him]"](http://lavabit.com) seems irresponsible, given that Lavabit was an LLC formed
explicitly to protect against this sort of intrusion.

### Legislation Please

Court rulings on new technology are mostly reasoned from statutes designed for
the telephone system. This results in needless thrashing over interpretation. Take for instance part of the statute ([18 U.S. Code § 3124](http://www.law.cornell.edu/uscode/text/18/3124)) covering what assistance Lavabit should provide the FBI in setting up monitoring:

> [the company] shall install such device forthwith on the appropriate line or
> other facility and shall furnish such investigative or law enforcement
> officer all additional information, facilities and technical assistance
> including installation and operation of the device unobtrusively

This language is awkward when applied to computer systems, particularly in the
face of encryption and shared hosting.

The FBI's device apparently had the ability to monitor _all_ email into the
system—assuming they can get appropriate private keys—and only forward relevant ones to
humans for review. This isn't a situation telephonic devices needed to deal
with, and could arguably be in violation of the Fourth Amendment.
How is relevant defined? Given the wide access, do we need a higher standard of
trust that that criteria is being met?[^3]

[^3]: Given this is lawful monitoring activity, and assuming relevance must be on non-content metadata which there are limited ways to avoid, perhaps an open-source device is appropriate?

Both sides tried different metaphors to characterize this use of private keys,
from compelling all hotels to have glass doors, to a business owner
obstructing the law merely by placing a lock on his gate. Neither are
satisfactory.

Legislation specifically addressing computer systems would provide much needed
clarity.

This is not all to say that Levison deserved what happened, or to comment on
the legality of either party's actions. But Lavabit fought the law, and the law
won. It's prudent for us to learn from that.
