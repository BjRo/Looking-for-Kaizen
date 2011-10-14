---
author: BjRo
date: '2009-07-09 19:38:05'
layout: post
slug: diving-into-the-storyteller-trunk
status: publish
title: Diving into the StoryTeller trunk
wordpress_id: '390'
? ''
: - StoryTeller
  - StoryTeller
  - StoryTeller
  - StoryTeller
---

I just finished watching Jeremy D. Millers ["Presentation
Patterns"](http://media01.smartcom.no/Microsite/go.aspx?eventid=4463&urlback=null&bitrate=665548)
talk from this years [NDC](http://www.ndc2009.no/en/).

What he showed in the talk reminded me a lot of a prototype we build at
my last employer. The basic patterns & principles we used are mostly the
same. Composite app, testable presentation layer, Presenter-First, IoC,
Event-Brokering with auto-registration, just to name a few.

I'm still really pleased with most of the code we wrote that time.
However, today I believe we didn't get responsibilities right when it
comes to the whole screen creation & screen activation lifecycle. This
was mainly done by a single component (the Region) in close
collaboration with the presenters. The Region did it's job, but it was
effectively way to big and did too much. Besides that it was hard to
integrate some other stuff we wanted to do in an easy usable way
(context dependent command bindings for instance). I guess we hadn't
really internalized SOLID at that time. (To be honest, I'm still
struggling with applying it correctly more often as I like).

Jeremy's ["Build your own
CAB"](http://codebetter.com/blogs/jeremy.miller/archive/2007/07/25/the-build-your-own-cab-series-table-of-contents.aspx)
series was a real inspiration for our prototype. Some of the parts he
described (especially the thing with the ScreenConductor) were a bit
unclear for us, though. It's good to finally have example code, which
can be examined, executed and learned from.

I must admit I'm pretty impressed judging from what I've seen so far in
the talk. Pretty good stuff. Because of that I decided to spend some
extra time with the StoryTeller sources over the next weeks and do some
Ayende-like
I-write-this-while-I'm-looking-at-it-and-trying-to-figure-out-how-it-works-posts
(Don't get me wrong , I love them).
