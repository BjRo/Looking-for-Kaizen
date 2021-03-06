---
author: BjRo
date: '2009-08-07 19:42:40'
layout: post
slug: diving-into-the-storyteller-trunk-part-6-the-main-players-in-the-screen-activation-lifecycle
status: publish
title: 'Diving into the StoryTeller trunk, Part 6: The main players in the screen
  activation lifecycle'
wordpress_id: '469'
comments: true
footer: true
categories: [dotnet, StoryTeller]
---

It has been an interesting time with the StoryTeller codebase so far.
I've learned a lot about advanced StructureMap usage by scanning through
the code, trying to understand the unit tests, debugging StoryTeller and
writing some smaller programs based on the newly discovered patterns &
features. However, my initial motivation for spending time with that
codebase wasn't StructureMap or the Convention over Configuration topic
but rather StoryTellers implementation of the screen activation
lifecycle. Jeremy wrote bits about it in his "Build your Own Cab"
series, but they where rather abstract and didn't show a lot of code.
Many responsibilities he described seemed totally logical to me, but I
had trouble putting all those concepts together into code (which mostly
undermines that I only understood have of the stuff I read ;-)). Things
became really interesting again when Jeremy showed more parts at the
Presentation Patterns talk at last NDC. Damn, I wasn't aware that a lot
of the patterns he described were already implemented in the StoryTeller
codebase (or did they emerge after the recent rewrite ???). With part 6
of my Story Teller journey I would like to spend some time describing
the general players in the screen activation lifecycle. This will be a
no-code-post. A high level view so to say. 

ScreenCollection
------------------
In his Presentation Patterns talk Jeremy described that the kind of desktop
application he worked on in the past implemented mostly one of two major
navigation styles: Tab-style navigation or Web-style-navigation..

-   Tab-style-navigation more or less means that every new screen or
    control is displayed on a different tab, a new content control in
    the UI.
-   Web-style-navigation means that every new screen or control is
    mostly displayed in the same content control and replaces the
    previously displayed control. Basically a way how a browser handles
    things (of course, in the old ages before the empire, hm I mean tab
    ;-)).

StoryTeller implements a Tab-style navigation. However you don't
interact with a TabControl directly in StoryTeller . It is exposed via
the `IScreenCollection` interface. The functionality of this interface is
mostly similar to CAL/CAG/PRISMs `IRegion` or the old `IWorkspace` interface
in CAB. However there's a huge difference in what the `IScreenCollection`
accepts in his `Open`, `Close` or `Activate` methods. They don't accept
UserControls or UIElements, they accept only instances implementing the
`IScreen` interface. 

Screen
----------
The complete screen activation lifecycle in StoryTeller is based on the `IScreen` interface and therefore
completely decoupled from the related UI technology. Testability, baby !!! 

The screen interface is mostly implemented directly by Presenters or ViewModels and exposes methods for determining current caption for the
screen, or the activation and deactivation of commands. Screens are
created by a `ScreenSubject`. 

ScreenSubject 
-------------
`ScreenSubject` is a really nice abstraction which deals with the creation and the identification of
a particular screen. This abstraction is really valuable in applications which behave a lot like Visual Studio when opening code files. Think
about it, when you first open up a source code file by double clicking it in the Source Code Explorer a new tab or window is created for it.
Double clicking the file again doesn't open a new window but rather activates the related tab or window. That's exactly what the
ScreenSubject abstraction tries to achieve, too. Freeing the consumer code from the decision whether to create a new screen or to activate an
already existing screen is the responsibility of the `ScreenSubject`
implementations. 

ShellConductor 
-----------------
The `ShellConductor` is THE BIG PLAYER in the screen activation lifecycle. In Martin Fowlers terms the
`ShellConductor` fulfills the role of the `ApplicationController`. The `ShellConductor` is the piece of code that (besides some other topics)
controls and coordinates the whole Screen handling. He is responsible for screen activation and deactivation, controls the closing of Screens
and acts as kind of a facade for typical application code working with the framework. You could say that the ScreenConductor is an
`ApplicationController` broken down into more smaller, specialized parts.

As you can imagine the `ShellConductor` knows a lot of his buddies in the neighborhood. Just to give you an impression how a typical operation on
it might look like, I'd like to walk you through the simple topic of opening a screen in the UI. Here are the Steps:

1.  Client code calls `OpenScreen(new MyScreenSubject())` on the
    `ShellConductor`.
2.  `ShellConductor` knows the `ScreenCollection` and tries to find a `IScreen`
    matching the subject in the collection.
3.  If a Screen was found, it's activated.
4.  If no Screen was found, the `ShellConductor`
    1.  creates the target screen via the supplied `ScreenSubject`,
    2.  adds it to the `ScreenCollection` and
    3.  activates it in the `ScreenCollection`.

The `ShellConductor` will be a larger topic I'm going to look into in one
of the next posts, so please forgive me for the moment if I continue my
overview with the last element for today, the `Shell`. 

Shell 
--------
The `Shell` is the host window for the application. It's the frame in which the
`ScreenCollection` and `Screens` are displayed. It's actually pretty dumb,
since it only has kind of a container functionality. 

What I didn't touch today 
---------------------------
To be honest there is a more in the StoryTeller UI layer
than the stuff I described today. On of the major topics for instance I
left out for the moment is the whole topic dealing with `Commands`,
`CommandBindings` and `InputGestures`. StoryTeller shows a nice way of how to use a little internal Dsl for defining Commands on the fly. So far
I've looked at it only sufficiently but it looks really promising. I'm
definitely going to spend a post or two for that topic, so stay tuned.

See you next time when it's time to look at some code again . . .
