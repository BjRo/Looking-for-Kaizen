---
author: BjRo
date: '2009-08-17 12:36:45'
layout: post
slug: wpf-is-not-winforms
status: publish
title: WPF is not WinForms
wordpress_id: '485'
comments: true
footer: true
categories: [dotnet]
---

I've been investing a lot of time in learning WPF lately. WPF has always been somehow interesting to me, however I never found actually
the time to learn it from the ground up. I've been trying to grok it for several weeks know and am now slowly coming to a point were I can feel
the ROI, start seeing the big picture (how the whole WPF architecture fits together) and what's the really beneficial side of WPF compared to
WinForms. 

I've read several times about how steep the learning curve is and must admit, yeah that's probably right. At least I've experienced it
that way. BUT, here is the interesting side node: That's mostly not because of the difficulty or complexity of the technology itself. A lot
of my problems arose because of the way how I tried to approach WPF.  Having spend most of my professional work with WinForms seems to have
left some traces. I remember lots and lots of situations where I thought to myself: *"Why is that so hard? In WinForms you must simply . . ."*,
*"This TreeView just plain sucks"* or *"Mh, where is the Dock property on a Control?"*. 

Makes me smile now when I think about it. What I basically experienced is **THAT IT'S HARD TO DO WINFORMS DEVELOPMENT WITH WPF**. WPF was never designed to be WinForms V2. 
Neither was it designed to have a similar programming model. After realizing this here is a little yoda-eske advice for WPF-learners like me: 

{% blockquote %}
Don't let you're WinForms knowledge stand in your way. Try to really understand the programming model and the intentions of WPF first and constantly
review whether problems you experience while learning WPF come from trying to do the things the way you're used to in WinForms.
{% endblockquote %}

Once I've understood that I really felt that I made a big leap forward. WPF is such a rich, enjoyable technology if you stick with it long enough.
Sadly I'm currently not participating in a WPF or Silverlight project (like so may others), but I've high hopes. Better times are coming . . .
