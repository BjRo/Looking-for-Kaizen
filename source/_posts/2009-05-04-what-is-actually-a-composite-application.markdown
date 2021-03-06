---
author: BjRo
date: '2009-05-04 23:04:40'
layout: post
slug: what-is-actually-a-composite-application
status: publish
title: What is actually a composite application?
wordpress_id: '331'
comments: true
footer: true
categories: [dotnet, sw-design]
---

'Composite application' is one of those terms you talk endlessly with other developers about, only to find out that each of them has a totally
different understanding of what the term actually means. If you try to google it you'll find several definitions ranging from 'a solution
stitched composed of loosely coupled semi-independent components' over 'application built by combining multiple existing functions into a new
application' over 'business mashups' to 'frontends to a Service Oriented Architecture'. Just to be clear, I like none of those definitions and I
won't give you a formal definition either. Instead I would like to take quick look at the key differences (as I see them) between composite
applications and conventional architectures. If take a look at how software developers & architects deal with complexity IMHO it mostly
boils down to two things: 1. Decomposition and 2. Integration. Complex problems get broken down into handier pieces which can be solved more
easily. We apply this divide-and-conquer-strategy at multiple levels (classes, algorithms, components, layers, tiers, just to name a few). We
do this to achieve all sort of things like maintainability, reversibility, testability, etc. However, in order to have a working
solution you need to reintegrate all those parts and that integration aspect for me personally is one of the main differences between
conventional and composite architectures:

-   Integration in conventional architectures is performed in a static way, mainly by the compiler but also by deployment tools (f.e.
    ILMerge).
-   Compared to that, integration in composite architectures is more or less dynamic. It's performed at runtime by some kind of integration
    architecture with a kernel built around the concept of dependency inversion. When inspecting composite applications you'll very often
    find a host-process which dynamically loads modules and a container based infrastructure which does the actual low level composition.
    This container can be an actual Inversion-of-Control-container, but this isn't a must. The Managed Extensibility Framework for instance
    is able to achieve similar things.

Besides that, another aspect really important to composite architecture is the **Open-Closed-Principle applied to architecture**. 

OCP was originally formulated by Uncle Bob Martin as 

>software entities (classes, modules, functions, etc.) should be open for extension, but closed for modification. 

What does this mean to architecture? It basically means that you're able extend your host environment without
having the need to recompile it. This can range from adding a new module to the system, over registering new business capabilities to extending
the UI of host environment (which is called the shell). So far I've talked a bit about the IMHO typical aspects of composite applications,
but not why you might want to use such an architecture and what possible benefits of such an architecture might be. I guess this is worth an own
post, so I'll spare that for now . . . .
