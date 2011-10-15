---
author: BjRo
date: '2008-06-30 22:01:15'
layout: post
slug: yet-another-way-to-do-publish-subscribe
status: publish
title: Yet another way to do publish & subscribe . . .
wordpress_id: '8'
comments: true
footer: true
categories: [dotnet, sw-design]
---

About 2,5 years ago I first came across the idea of combining dependency
injection with loosly coupled publish & subscribe. This was when I
inspected the source code of the [Composite Application Block (CAB)](http://msdn.microsoft.com/en-us/library/aa480450.aspx) with its
underlying InversionOfControl-container ObjectBuilder from Microsoft.
What I liked about publish & subscribe in CAB:

-   The automatic thread marshalling. (Basically you're able to specify
    whether the subscription-callback will be handled on the UI-thread
    or the same thread as the publisher)
-   The wiring was done during the build process in the ObjectBuilder.
    Publishers and Subscribers are completely decoupled. Wow, this was
    pretty amazing for me when I discovered that late 2005 :-).

What I didn't like about it:

-   It is very tightly coupled to a CAB internal data structure called
    WorkItem. (Not reusable outside the scope of CAB)
-   It uses standard .NET events / delegates. (The publisher needed to
    define an event and the subscriber needed to have a public method
    with a matching "object-sender-eventargs-e" - signature.)
-   It uses attributes and especially a string based topic identifier to
    correlate publishers for a topic and corresponding subscribers.
    (Maybe I'm narrow-minded on this, but I think the simplest way to
    specify a subscription is the best, which imho is expressing a
    subscription by implementing an interface.)

Many frameworks or libraries I looked into over time mostly followed a
comparable approach using either events or some other delegate-based
solution (the EventBroker in CAB, the EventBrokerFacility in Castle
Windsor, the EventAggregator in PRISM, ....) (Please correct me if I
overlooked or misunderstood something :-)). 

The only framework I came across with something similar to what I had in mind is
[Caliburn](http://devlicio.us/blogs/rob_eisenberg/archive/2008/01/07/introducing-caliburn-an-mvc-mvp-wpf-framework.aspx).
Unfortunately Caliburn is a WPF/ .NET 3.0 based framework, but most of
the products of my current employer are limited to .NET 2.0 due to a
minimum system requirement of Windows 2k. 

Because of that I decided to implement something similar for our purposes which can be easily
integrated into the InversionOfControl - container of our choice (which
is Castle Windsor at the moment, by the way :-) ). I'll be describing
the implementation and publish the source code for anyone who is
interested in one or more follow-up posts . . . .
