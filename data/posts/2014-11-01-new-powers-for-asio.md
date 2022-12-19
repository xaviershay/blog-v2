---
layout: post
title: "New powers for ASIO"
category: articles
tags: ["politics"]
---

Australian Parliament recently passed the [_National Security Legislation
Amendment Bill_][bill], and it the last couple of days has gone into effect[^1]. It provides a much needed update of the [_Australian
Security Intelligence Organisation (ASIO) Act 1979_][act] to cope with modern
technologies and employment arrangements. The bill is presented as seven distinct "schedules". Four of the schedules are uncontroversial, and were uncontested by any party:

* **Schedule One** clarifies the roles and powers of _ASIO affiliates_ (such as contractors), delegation of powers by the director, and secondments to other agencies.
* **Schedule Four** is the smallest, adding a provision allowing ASIO to cooperate with _anyone_ rather than a defined list of agencies.
* **Schedule Five** expands the scope of ASIO investigations to include "activities that pose a risk, or are likely to pose a risk, to the operational security of ASIS". This is sensible, but ominous when combined with the recent governmental abuse of ["operational matters" secrecy][comic].
* **Schedule Seven** is a find and replace of _Defence Imagery and Geospatial Organisation (DIGO)_ and _Defence Signals Directorate (DSD)_ to _Australian Geospatial Organiation (AGO)_ and _Australian Signals Directorate (ASD)_ respectively. They weren't being patriotic enough.

The remaining three schedules are problematic.

### The Network Is The Computer

Schedule 2, item 4 proposes a new definition of "computer" for purposes of government hacking:

> "computer" means all or part of:
    (a) one or more computers; or
    (b) one or more computer systems; or
    (c) one or more computer networks; or
    (d) any combination of the above.

Any target computer (or system, or network, etc) does need to be limited by a Computer Access Warrant in [section 25A][25a], amended by [Schedule 2, Item 18][s2i18]:

> The target computer may be any one or more of the following:
                     (a)  a particular computer;
                     (b)  a computer on particular premises;
                     (c)  a computer associated with, used by or likely to be used by, a person (whose identity may or may not be known).

Per the original act, the warrant can only be granted on:

> reasonable grounds for believing that access by the Organisation to data held in a particular computer (the target computer) will substantially assist the collection of intelligence in accordance with this Act in respect of a matter (the security matter) that is important in relation to security.

But this amendment allows for, if all other effective and reasonable methods have been tried:

> using any other computer or a communication in transit to access the relevant data and, if necessary to achieve that purpose, adding, copying, deleting or altering other data in the computer or the communication in transit

These warrants are issued by a minister, not the judiciary, and the target does not ever need to be informed about the warrant.

In summary, this amendment effectively allows for large scale government hacking against Australia citizens, such as a no-notice compromise of a university or library network[^2] the target is expected to interact with, with no independent oversight.

Two reasonable restrictions were proposed by The Greens, independent Senator Xenophon, and others:

1. [Yearly public reporting][amdt-1] of the number of computers accessed under warrants.
2. A [high limit][amdt-2] on the number of devices that can be accessed with a single warrant. The Greens proposed twenty, but just as a starting number: they were open to any arbitrary limit.

[amdt-1]: http://parlinfo.aph.gov.au/parlInfo/download/legislation/amend/s969_amend_a56e7506-b2e7-43a3-ae96-e11ccd4b369a/upload_pdf/7582_CW_National%20Security%20Legislation%20Amendment%20Bill%20(No.%201)%202014_Xenophon.pdf;fileType=application%2Fpdf
[amdt-2]: http://parlinfo.aph.gov.au/parlInfo/download/legislation/amend/s969_amend_4a0236a1-49da-4d72-9d47-5694022fbd55/upload_pdf/7570_CW_National%20Security%20Legislation%20Amendment%20Bill%20(No.%201)%202014_Ludlam.pdf;fileType=application%2Fpdf

Both suggestions were rejected.

### Criminal Immunity

Schedule 3 grants criminal and civil immunity to anyone involved in a "Special Intelligence Operation". This is a new type of operation that must be explicitly authorised by the Minister, but has no defined urgency or criticality requirements. As [noted by][asioland] public interest lawyer Elizabeth O'Shea:

> A SIO is basically just an operation that been approved as such (s 35C(2)) – there is no requirement that the substance of the operation is particularly secret or time sensitive, or that there is an imminent risk to life or health.

The operation must limit any unlawful activity to "the maximum extent consistent with conducting and effective [operation]" (s 35C(2)c), but that doesn't seem much of a restriction. There is no necessary specification of the actual unlawful behaviour permitted, and illegally obtained evidence is protected under section 35A(2).

Certain grave crimes are not covered by immunity: murder or serious injury, sexual offences, significant loss or serious damage to property, and torture. Disturbingly, torture wasn't exempted in the [initial draft][initial-draft] of the bill and was only added after objections from the opposition.

### A Freeze Is Coming

Schedule 6 increases the penalty for unauthorized disclosure of information from two to ten years, with a new three year penalty for "inappropriate handling" of information, even if it is not disclosed. This first covers third-parties as well, such as journalists who distribute such information.

Given recent NSA revelations (an agency in a similar position), and the already limited oversight and overreaching powers of ASIO[^3], this is a scary proposition. Think to yourself: would you do the right thing if it risked only two years in prison? How about ten? To my mind the former is ponderable, the latter is a lifetime.

Senator Xenaphon [proposed judidial disgression in an amendment][amdt-3] that:

> A court must, in determining a sentence to be passed or an order to be made
> in respect of a person for an offence against subsection (1), take account of
> whether or not, to the knowledge of the court, the disclosure was in the
> public interest.

[amdt-3]: http://parlinfo.aph.gov.au/parlInfo/download/legislation/amend/s969_amend_64fda20c-f4e3-47e7-8a25-7550415cdbb4/upload_pdf/7574_CW_National%20Security%20Legislation%20Amendment%20Bill%20(No.%201)%202014_Xenophon.pdf;fileType=application%2Fpdf

It was rejected.

### The Police State

Many of the amendments are indeed needed and welcome: computers have changed substantially since 1979 and the law needs an update to accomodate. But this does not legitimize gross expansion of secret powers. This bill is just one of three introduced this year, the other two conferring even more powers to our intelligence body.  How much further will our civil liberties be eroded?

[bill]: http://www.aph.gov.au/Parliamentary_Business/Bills_Legislation/Bills_Search_Results/Result?bId=s969
[act]: http://www.comlaw.gov.au/Details/C2014C00680
[comic]: http://www.kudelka.com.au/tag/operational-matters/
[25a]: http://www.comlaw.gov.au/Details/C2014C00680/Html/Text#_Toc400617845
[s2i18]: http://www.comlaw.gov.au/Details/C2014C00680/Html/Text#_Toc400617951
[entire-internet]: http://www.smh.com.au/digital-life/consumer-security/new-laws-could-give-asio-a-warrant-for-the-entire-internet-jail-journalists-and-whistleblowers-20140923-10kzjz.html
[asioland]: https://overland.org.au/2014/10/asioland/
[initial-draft]: http://parlinfo.aph.gov.au/parlInfo/download/legislation/bills/s969_first-senate/toc_pdf/1417820.pdf;fileType=application%2Fpdf

[^1]: Schedules 1-6, which include all those criticized in this post, commence "the 28th day after this Act receives the Royal Assent." Assent was granted 2nd October 2014.
[^2]: Claims that this allows the government to target ["the entire internet"][entire-internet] seem overblown to me. Though of course, how would we know?
[^3]: [ASIO can _already_][asioland] detain citizens for a week with no explanation, forbid them from contacting anyone, veto their choice of lawyer, and compel them to self-incriminate.
