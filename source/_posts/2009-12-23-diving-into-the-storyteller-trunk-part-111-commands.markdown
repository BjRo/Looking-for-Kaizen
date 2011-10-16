---
author: BjRo
date: '2009-12-23 20:16:13'
layout: post
slug: diving-into-the-storyteller-trunk-part-111-commands
status: publish
title: 'Diving into the StoryTeller trunk, Part 11.1: Commands'
wordpress_id: '651'
comments: true
footer: true
categories: [dotnet, StoryTeller]
---

Welcome back to the **Diving into the StoryTeller trunk** series. The main
topic for the last couple of posts about StoryTeller is its Command handling or to be a bit more specific the reoccurring problem of how
Screen related Commands are managed in the app infrastructure. Couple of posts? Yeah, right. Today's post is going to be a bit shorter than the
usual posts in the series. When I started to write this post I quickly realized that this topic contains more aspects to talk about than I had
originally anticipated. Besides that Christmas is near, I'm running out of time for this year and just wanted to get at least some bits of the
content out there before going on vacation. Today's post is going to be more general one on the topic. 

The Command Pattern 
------------------------
A lot of the content in this series dealt exclusively with how the StoryTeller UI layer manages Screens in its content area, 
but as you know most of the time an application consists of more parts than just the plain content area. A typical desktop application is probably going to have some sort
of Mainmenu, a Statusbar and of course Contextmenus. Items displayed in those areas very often represent actions an application can perform.
They act as a trigger of those actions. A typical way to implement this is using the [GoF-Command Pattern](http://en.wikipedia.org/wiki/Command_pattern), which separates
the invoker of an action (for instance a button) from the receiver instance which executes the action by introducing the Command abstraction. A Command encapsulates the knowledge needed for an
invokation of the receiver instance, so that it can be executed at a later time. 

Commands are potentially contextual 
-----------------------------------------
An application can have lots and lots of Commands. While some of these Commands are available all of the time, some of them can only be executed in a particular context. 
A typical example for Commands of the first category might be the "Exit application" Command. A typical example for the latter category might be the "Undo" Command or "Redo" Command in all
kinds of text editors, which can only be executed when the currently viewed document has some changes. It's not uncommon to have lots of contextual Commands in an application that are only related to a very
specific Screen or Screen state. When we think in terms of usability, the least a user should be able to take granted from an app is that the
app appropriately shows which actions can be performed at a particular point of time. This can be achieved by enabling / disabling related
items depending on the availability of the Command (be it manually or through databinding). Sometimes though,it might be a better approach to
have an even more contextualized UI that only shows the commands related to the current context. So for instance if no code editor view is shown
in Visual Studio than the "Undo" and "Redo" Commands should also not be visible (NOTE: VS doesn't actually behave that way). I think this idea
of contextualized UIs becomes more and more popular. Office 2007/2010 was build with this idea in mind. 

Commands in a Composite UI
----------------------------
Composite UIs which follow the Open / Closed Principle add another problem to the mix. When new modules or new screens are loaded into a
composite app, they shouldn't need to modify the app infrastructure in order to add their related commands. The app infrastructure needs to
provide a way to plug those commands in without modification. This also includes their visual representation (Text, Tooltip, Icon, etc.).

Questions we should take a closer look at
------------------------------------------

-   Do we need to differentiate between types of Commands?
-   Who is responsible for adding / registering commands?
-   How is the visual representation of commands configured?
-   Who is responsible for deciding whether Commands are available?
-   Is there build-in .NET Framework support for this?
-   **Of course: How does StoryTeller implement all this?**

I'm afraid that's all for today. I wish you all merry Christmas and a
happy new year. See you in 2010
