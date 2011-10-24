---
author: BjRo
date: '2009-03-30 22:53:21'
layout: post
slug: composite-apps
status: publish
title: Composite Apps
wordpress_id: '326'
comments: true
footer: true
categories: [dotnet, sw-design]
---

I'm currently in the process of preparing material for a workshop at my current client. The workshop will be mainly focused on implementing
client-side Composite Apps with the Composite UI Application Block / SCSF but it'll also contain a large portion about Composite Apps in
general. While the CAB / SCSF is good documented in several blogs, I'm not aware of a good overview on the general part of Composite Apps,
especially when it comes to typical pitfalls of such architectures and how to avoid them. I believe that a lot of the problems related to such
architectures are reoccuring (like patterns). At least I've seen them on the last three apps I worked on. Bottomline: I thought it might be a
good idea to share my current view on the topic and discuss it in further posts. Stuff I'm planing to cover:

-   [What is actually a Composite App?]({{ root_url }}/2009/05/04/what-is-actually-a-composite-application/)
-   When should you invest in a composite architecture?
-   Typical pitfall: Assembly explosion
-   Typical pitfall: The composite monolith aka broken module autonomy (This will probably be more than just one post)
-   Typical pitfall: Nontransparent remote calls
-   Typical pitfall: Synchronous communication

The index of content is work in progress and I don't consider it to be
complete. Feel free to post any suggestions and feedback . . . 

Stay tuned for more !
