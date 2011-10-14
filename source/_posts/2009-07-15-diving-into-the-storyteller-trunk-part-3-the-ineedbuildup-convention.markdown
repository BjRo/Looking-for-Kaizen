---
author: BjRo
date: '2009-07-15 23:11:18'
layout: post
slug: diving-into-the-storyteller-trunk-part-3-the-ineedbuildup-convention
status: publish
title: 'Diving into the StoryTeller trunk, Part 3: The INeedBuildUp convention'
wordpress_id: '415'
? ''
: - StoryTeller
  - StoryTeller
  - StructureMap
  - StructureMap
  - StoryTeller
  - StoryTeller
  - StructureMap
  - StructureMap
---

\

Another day in the trunk, another convention found. After all startable
instances have been started in the bootstrapping process, there is very
similar looking convention which acts upon the INeedBuildUp interface, a
marker interface. The code for it looks like this:

[code language="csharp"] ObjectFactory.Model.PluginTypes .Where(p =\>
p.Implements()) .Select(x =\> x.To()) .Each(ObjectFactory.BuildUp);
[/code]

For each contract type which is assignable to the INeedBuildUp type, it
first resolves the contract type (via ObjectFactory.GetInstance(Type))
and then performs a build up (via ObjectFactory.BuildUp(object)) on the
created instance.

When I initially saw this my first reaction was like â€œHm, aren't those
two methods doing more or less the same thing? (new vs. existing
instances) Why should you chain them? \
 \
As it turns out there's something wrong with my initial assessment. When
you take a look at the instances marked with the INeedBuildUp interface
you recognize some similarities between them:

1.  The marked classes are mostly WPF controls.
2.  They're explicitly registered with their contract type at the
    container after they have been created.
3.  They've got at least a single writable property marked with the
    SetterPropertyAttribute. (Property injection is not implicitly
    performed in StructureMap, it needs to be explicitly configured)

What I've missed in the first run is that you can of course register
existing instances for a contract type in the container. When calling
ObjectFactory.GetInstance for the particular contract type, then you
simply obtain a reference to the configured, already existing instance.
So chaining ObjectFactory.GetInstance and ObjectFactory.BuildUp makes
sense for inserting dependencies into an instance which was not created
by the IoC in the first place. Is this the case here?

WPF Controls need to have a parameter less constructor in order to work
properly with the XAML engine and the WPF-designer. Mh, is
WPF-Design-Time-support the origin of this convention? Seems to be, but
I'm not 100% sure. Besides that, is this something a convention should
be defined for? To be honest, I'm undetermined . . .
