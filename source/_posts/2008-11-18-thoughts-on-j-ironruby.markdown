---
author: BjRo
date: '2008-11-18 06:36:27'
layout: post
slug: thoughts-on-j-ironruby
status: publish
title: Thoughts on (J / Iron)Ruby
wordpress_id: '183'
comments: true
footer: true
categories: [Conferences]
---

Today I attended a tutorial about JRuby and JRuby on Rails. It was presented by Ola Bini from Thoughtworks, who did the more general part
on (J)Ruby and Nick Sieger from Sun, who did the Rails stuff. What can I say, it was really cool.

I've been curious about Ruby for quite a while now, mostly because of its influence on the .NET open source community (MSpec, MonoRail,
Asp.net MCV, etc.) , but also because my personal interest in internal domain specific languages. It's a lot easier to build internal domain
specific languages with Ruby than it's with a statically typed languages like C# or Java. Compare RSpec for instance with its C# counterpart
MSpec and you instantly realize the difference when it comes to terms of readability and less code to write in order to get things done. 
 
What was interesting in this talk in particular is the fact that most of the things that apply to JRuby and Java also apply (or will apply) to
IronRuby and .NET: 

-   **The reuse of existing IT infrastructure**. In the not so far future Rails will be able to be run on top of .NET and IIS. No
    existing Ruby infrastructure will be needed in order to get it running. No new server / infrastructure know how will be needed for
    running Rails in a .NET environment.
-   **The integration between a statically typed platform and Ruby in both directions**. C# will be able to integrate dynamically typed
    code (C# keyword dynamic) and pure Ruby applications can be run on top of .NET. Besides that IronRuby will also have a fantastic
    integration of the .NET framework libraries and will be able to extend its view of the .NET world with Ruby concepts (I think it's
    called monkey patching). Opening up and extending .NET types from IronRuby and support for snake casing for members on .NET Framework
    built-in types are some of the nice features.

It'll be interesting to see the impact of IronRuby on the .NET OS community. My guess is that the overall adoption rate of IronRuby in
that circle will be pretty high (assuming that Microsoft succeeds in delivering a first class implementation of Ruby). Ruby has the potential
to enable a more language oriented style of programming on the platform, which is exactly what a lot of .NET OS key players are striving for. 
 
Writing more expressive, readable and maintainable code has always been important for me too and one of the consequences of today is that I'll
definitely will invest more time into Ruby and IronRuby in the near future. I'm curious to hear opinions about IronRuby and its impact on
the .NET community . . . 
 
Bye the way: Is Rails a software factory? A lot of the things I saw today reminded me of software factories . . .
