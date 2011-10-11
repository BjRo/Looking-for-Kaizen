---
author: BjRo
date: '2010-06-21 07:46:59'
layout: post
slug: net-open-space-sd-retrospective
status: publish
title: .NET Open Space Süd Retrospective
wordpress_id: '810'
categories: [Conference, NOS_SUED]
comments: true
---
I haven't blogged in a while, mostly because time has become such a limited resource in the last weeks or to be honest actually months. 
Blogging, my current project, workshops, the F# Bookclub, preparation of the next conference appearances and of course xUnit.BDDExtensions all want a piece of that cake. 
Finding the right balance between those tasks is often not as easy as I would like it to be. 
More often as I like skipping blogging seems to be the easiest way to regain some time. 
I’m really sorry for that, but you know I try to do my best. 
On the other hand this is a new blog post, so things can’t be that bad, can’t they? 
Although I haven’t slept much the last 3 days, something inside me urges to write this post.

Most of the time of the past weekend I spend in Karlsruhe at the .NET Open Space Süd. To sum it up in 5 words: **The event was a blast**. 
I had an unbelievable amount of fun coding, chatting, learning with some of smartest people in the German .NET Community.    

This was the 4th Open Space event I attended during the last 2 years and I think this one was the best so far. Why?  

1. The content of the sessions I attended / participated in was really high quality. I learned something new in every fracking session. Every session was dense, 
  focused and we had at least one participant who actually had extensive field experience in the related topic area. No CQRS session disaster this time ;-)         
2. Overly generic topics ala “I want to talk about TDD” or “Let’s talk about (D)DDD” were the minority.     

Besides that, one personal note: It was a blast to meet some of the guys I got to know throughout the last 2 years again and see the personal progression each of them has made. 
Guys, your awesome. Keep up your pace!   

So, just to give you an idea about the sessions I attended here’s a quick sum-up of my weekend @NOS_SUED.    

WTF is a Monad? (C# Edition)
---------------------------------
The first day started with one of the hardest topics you might imagine, Monads. 
@sforkmann did a great job explaining the various basic monadic types and their implementation in C#. 
Helped me a lot to form a better picture of this abstract concept in my mind. Was nice to see the Maybe Monad implemented using query comprehension syntax 
(though we found out that the related msdn sample doesn’t compile aka sucks). Sadly we didn’t have time enough to take a look at Monads in F#. Homework, I guess.  

Funny side note: The word “Monad” was present throughout the complete weekend. 
I guess the revelation that most of us have been using a Monad for quite a while now (in LINQ), though not knowing it, shocked quite a bunch of participants.

Git tips & tricks 
-------------------
Next up was @agross with Git. I never forgot that Alex was the person that told me about this “Git thing” two years ago, long before the topic suddenly 
started to get the attentions of the .NET OS community. Main focus of this session was the various approaches around conflict resolution and a detailed 
look at the difference between merging and rebasing.    

Especially interesting was to hear a bit more about this experience with Git in the context of a popular .NET OS project (Alex is one of the core maintainers of MSpec).

Convention over Configuration
-----------------------------
Halfway through Saturday I talked a bit about my experience with “Convention over Configuration”. 
My current project uses conventions a lot (but only for binding, thx @ilkerde for the clarification) and I’m really happy with the outcome so far. 
On retrospective I think @ilkerde, @agross and myself did a really good job in categorizing the various ways CoC can be applied from sourcecode, 
to builds to deployment. 

BDD vs. ATDD
------------------
The biggest session I participated in was the (dunno what was the exact name of the session) 
“Behavior Driven Development vs. classic Acceptance Test Driven Development” session. Was cool to have @agross (MSpec maintainer), 
@ssishkin ( my personal Fitnesse guru), @sforkmann (creator of NaturalSpec), @DerAlbert and several others who’ve been doing BDD, 
something BDD-like or ATTD in a room and hearing their various war stories and views on the topic.

Introduction to Reactive Extensions
------------------------------------
If you start a day with Monads to be consequent you need to end it with Monads, too. @sshishkin and @sforkmann gave an interesting talk about the ideas behind IObserver, 
IObservable and IQbservable. BTW, how cool is this IQbservable idea?

Specification By Example Do’s & Dont’ s
--------------------------------------------
In this session we took a look at the various proven practices in BDD specification design and the other side of the coin, 
the different flavors of specification smells. We discussed the ObjectMother pattern, TestData Builder Pattern, 
modularization strategies for specs and especially the idea of having the specifications side-by-side with the actual production 
code in a single assembly. Very good to see other proponents of this idea.

I was literally blown away by finally seeing the grouping functionality for Visual Studio,
I always wanted to have, [alive](http://mokosh.co.uk/wp-content/uploads/2010/04/image23.png). [VsCommands](http://mokosh.co.uk/vscommands/), I’m going to install you today!

Behavior Driven Development BDD Framework - Shootout (MSpec vs. NaturalSpec vs. xUnit.BDDExtensions)
-----------------------------------------------------------------------------------------------------
The (un)conference ended for me with a side-by-side comparison of different BDD frameworks. 
Several guys asked for this. I guess it makes sense when you’ve got the authors of 3 different frameworks for a particular topic together.
Although I didn’t like the idea at first sight (I don’t like framework wars that much, besides in the end the idea of BDD matters, and not the tools) the session turned 
out to be a win for all of us. We demo-ed the typical bank transfer sample in each of the frameworks (MSpec, xUnit.BDDExtensions, NaturalSpec). 
Afterwards every framework owner demo-ed additional features more or less unique to the particular framework. I guess, each of us got ideas for “new” features ;-)

Closing thoughts
--------------------------
I really enjoyed being in Karsruhe. Big thx to the organization team for making this event possible. I hope to see some of you again at the Open Space in Leipzig later this year or same place next year.  

Special thx to @agross, @sforkmann, @ilkerde, @roeb and @sshiskin for the intense and inside-full discussions. You rock guys!!!

One last advice: Don’t forget **Jean Clojure’s basal monad**
