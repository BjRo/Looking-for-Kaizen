---
author: BjRo
date: '2009-11-30 10:56:11'
layout: post
slug: whats-next
status: publish
title: What's next?
wordpress_id: '641'
comments: true
footer: true
categories: [Uncategorized]
---

With the "Diving into the StoryTeller trunk series" coming to an end in the near future, I'm currently looking into several ideas for future
posts. Here's what I'm currently thinking about: 

1. **xUnit.BDDExtensions feature walkthrough and documentation** Let's be honest it's currently not documented at all. I failed big time at
documenting its usage scenarios and behavior so far. However, since more and more projects at my current client are starting to use it I'm
definitely going to fix this . . . 

2. **Look into various options to implement the Active Object Pattern** I've been reading several papers
about infrastructures for command execution lately. It's an interesting topic for distributed scenarios (for instance used in a CQSR design),
but also for local scenarios when you start to think about multi core / concurrent programming. As modern applications are becoming more and
more connected on the one hand and need to use local resources more efficiently on the other (because processors won't get a lot faster in
the near future) I think there's a huge need for having a simple consistent design for both. Things I'd like to look into are the
Concurrency Coordination Runtime, the .NET 4.0 Task Parallel Library and Application Spaces, as well as more specific topics like integrating
such an infrastructure with an MVVM design. 

3. **Dive into the Caliburn trunk** Last but not least I would love to spend some time with Caliburn
since WPF is more and more on my radar and Caliburn seems to fully embrace and extend a lot of the original WPF design ideas in a composite
context. I think I would do something similar to the StoryTeller series.  

So, what do you think? Any preferences? Any priorities?
