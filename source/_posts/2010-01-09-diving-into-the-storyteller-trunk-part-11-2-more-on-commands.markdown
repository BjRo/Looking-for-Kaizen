---
author: admin
date: '2010-01-09 20:38:35'
layout: post
slug: diving-into-the-storyteller-trunk-part-11-2-more-on-commands
status: publish
title: 'Diving into the StoryTeller trunk, Part 11.2: More on Commands'
wordpress_id: '737'
? ''
: - StoryTeller
  - StoryTeller
  - StoryTeller
  - StoryTeller
---

**!!! Updated to current StoryTeller trunk on 15.02.2010 !!!** Let’s
take a look at some of the questions I left unanswered in the last post.
**Is the basic GoF Command pattern sufficient for a modern composite
application?** The basic GoF Command pattern has no notion of visual
state of a Command, such as (Is)Enabled or (Is)Visible. Its original
purpose was to encapsulate an action, so that it can be passed around
and executed at some later point of time. Not more, not less.
[sourcecode language="csharp"] interface ICommand { void Execute(); }
[/sourcecode] Obviously real world desktop apps need something a bit
more sophisticated. I’ve seen several infrastructures in my (not so old)
career so far (home grown as well as OS alternatives), which extended
this basic idea with at least one of those properties mentioned above.
Take for instance the P&P Composite UI Application Block (now better
known as part of the Smart Client Software Factory). CAB implements a
delegate based variation on the Command pattern. The delegate represents
the action which is passed around. However, this delegate is managed by
the Command class which has a notion of Status. [sourcecode
language="csharp"] enum CommandStatus { Enabled, //visible and enabled
Disabled, //visible and disabled Unavailable //invisible } [/sourcecode]
The WPF Command infrastructure version of the Command interface is more
like the original pattern and adds the Enabled Property and an
EnabledChangedEvent to the interface definition. [sourcecode
language="csharp"] interface ICommand { void Execute(); bool Enabled
{get;} event EventHandler EnabledChanged; } [/sourcecode] To be honest
the Command interface **never looked like the original GoF definition in
ANY APPLICATION or project I’ve worked on so far**. It always had a
slight modification in one or another way. **StoryTeller’s Command
interface** StoryTeller is a WPF based application, so naturally it gets
the WPF Command infrastructure out of the box. However it composes the
WPF ICommand into a StoryTeller specific structure, the IScreenAction.
[sourcecode language="csharp"] public interface IScreenAction { bool
IsPermanent { get; set; } InputBinding Binding { get; set; } string Name
{ get; set; } Icon Icon { get; set; } ICommand Command { get; } bool
ShortcutOnly { get; set; } void BuildButton(ICommandBar bar); }
[/sourcecode] ScreenAction extends the capabilities of the original
GoF-Pattern with a lot of metadata, mostly for visual aspects (Icon,
Description). If you’re wondering why he included visual aspects: That
basically tries to solve a reoccurring problem in composite apps: In
composite applications modules are not known at compile time to the
infrastructure. Neither are all their capabilities and how they might be
displayed in the infrastructure shell. Because of that, the
infrastructure needs a dynamic, deferred way for doing the shells visual
configuration at application startup. One way to implement this is to
delegate the responsibility for setting this up to the modules itself.
This can be done during the module load time or every time a screen is
displayed. This fits very well with the idea of the Open Closed
Principle, since adding new modules/screens doesn’t require any
reconfiguration/recompilation of other modules or the infrastructure.
This is more or less the approach that StoryTeller takes. **Some
personal thoughts on IScreenAction** I’ve worked on three applications
in the past which followed down the same road. One thing I noticed
throughout those three applications is that this approach isn’t really
well suited when you’ve got strict and/or complex requirements about how
the UI of an application should look. Let me clarify a bit what I mean:

-   **The Ordering Problem**. Even if you organize tools representing
    commands in a simple toolbar (as StoryTeller does) you can very
    easily get into situations where the product owner wants to have the
    tools in a very specific order which is different to module load
    order, some internal event order, whatever. I’ve encountered this
    several times now. First time we solved this by introducing a global
    constant class containing tool names. Very, very bad idea, do not
    repeat this. This introduces a kind of hidden temporal coupling,
    because now modules must be loaded in a particular order (so that a
    tool already exists to which we can refer by name). StoryTellers
    take on this is a bit better (but IMHO not much). The Icon class has
    an Integer based Order property. All tools get sorted based on this
    property in StoryTellers CommandBar when it’s reloaded. This is less
    coupled, because it eliminates the temporal aspect of the coupling,
    but still has coupling.
-   **API bloat with visual aspects**. One area where I really started
    to find this approach annoying is when you stop having simple
    toolbars and start to use more complex menu types like for instance
    the Ribbon. Taking the ribbon as an example: Now don’t have simply
    an ordering problem, but at minimum an icon problem (Normal icon vs.
    Quick Access Toolbar), a size problem (Displayed large or small) and
    a positioning problem (/Tab/Group/ElementGroup vs.
    /ApplicationMenu/Left). We added all those stuff to our Command
    registration and guess what, we weren’t happy with that. We created
    a monster API actually doing very little.

So what do I (currently) prefer? Our current project (also using the
Ribbon) completely strips the visual aspect of the Command. Our Command
API looks very much like the WPF one, with the only addition of an Id
property. The whole visual aspect is configured using an XML file which
is loaded at application startup. [sourcecode language="xml"]
[/sourcecode] I think you get the point. It works very well for our
scope. (Slight warning though: This solution might not be the best in
case you need to represent menu state based on dynamically loaded data).
See you next time for: Commands strike back ;-)
