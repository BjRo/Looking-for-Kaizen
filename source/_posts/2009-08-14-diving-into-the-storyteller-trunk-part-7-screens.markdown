---
author: BjRo
date: '2009-08-14 17:04:15'
layout: post
slug: diving-into-the-storyteller-trunk-part-7-screens
status: publish
title: 'Diving into the StoryTeller trunk, Part 7: Screens'
wordpress_id: '476'
? ''
: - StoryTeller
  - StoryTeller
  - StoryTeller
  - StoryTeller
---

In the previous post I gave a short overview over the players that are
involved in the so called Screen Activation Lifecycle. Today I would
like to take a closer look at, guess what, the Screen.

For me personally, the design 'around' a Screen is one of the crutial
elements for success in developing a composite UI layer. Why do I think
so?

Mostly because it's one of the central points which connects the UI
infrastructure with all the rest of the application, the actual
application code. It's THE INTERFACE that fills you're framework /
infrastructure with life. If you fail here you probably feel the result
throughout the complete application. Day to day work happens around that
interface and since the UI seems to be one of those places in an
application that is very volatile and changes a lot, a Screen design
with principles like DRY and OCP in mind will make your life as an
application developer much easier.

So what are the basic responsibilities of a Screen?

-   First of all it provides content. While a composite UI's shell
    provides the hull of the application, the Screen provides the UI to
    fulfill a business requirement. I think it's comparable to the
    relationship between an Asp.Net Masterpage and the aspx pages
    displayed in its content placeholder (Disclaimer: I'm no Asp.net
    expert so feel free to correct).
-   Controlling Screen Activation. Since the UI infrastructure can't
    possibly now what has to happen when a Screen is activated, it
    delegates the responsibility to the Screen itself. A practical
    example of the Tell-Don't-Ask-principle. Interaction with the
    Command infrastructure mostly happens here.
-   Controlling Screen Deactivation / Closing. I've seen this in several
    applications now. A Screen with changed data can only be left /
    closed when a) changes have been persisted or b) the user votes to
    discard the changes. Like in point 2. the UI infrastructure can't
    possibly know when that's the case, so it's delegated.

With those 3 points in mind, let's take a look at the Screen interface
in StoryTeller. [sourcecode language="csharp"] public interface IScreen
{ object View { get; } string Title { get; } void
Activate(IScreeObjectRegistry screenObjects); bool CanClose(); }
[/sourcecode] Pretty straight forward, isn't it?. Next question, who is
actually implementing the interface? And the answer is surprisingly: It
depends! This interface can be implemented for instance by Passive View
- or Supervising Controller - style Presenters. It can be implemented by
ViewModels in Model-View-View-Model implementations. It can even be
implemented by UserControls (though StoryTeller uses this only for very
simplistic screens). It's a very pragmatic solution giving a lot of
choice to an application developer on how to interact with the UI
infrastructure.

I think that's a good choice. We, as a community, shouldn't be dogmatic
about MVVM vs. MVP, or the whole No-Code-Behind-debate. Consistency is
import but, sticking to a pattern not suited for a particular screen
(for instance using Passive View for a screen with a lot of fields) can
hurt much more than the (pattern) consistency would justify. Mh, that
was a little bit off-topic, wasnâ€™t it?

Most of the Screens in StoryTeller are classical Model View Presenter
implementations getting their view injected in the constructor.
[sourcecode language="csharp"] public class SuitePresenter : IListener,
ISuitePresenter, IListener { private readonly Cache \_drivers; private
readonly ITestExplorer \_explorer; private readonly ITestService
\_service; private readonly Suite \_suite; private readonly ISuiteView
\_view; public SuitePresenter(Suite suite, ISuiteView view,
ITestExplorer explorer, ITestService service) { \_suite = suite; \_view
= view; \_explorer = explorer; \_service = service; \_view.Presenter =
this; \_drivers = new Cache(t =\> \_view.AddTest(t, queueTest)); }
.......... } [/sourcecode] The structural aspect of the screens isn't
that interesting to me. Standard MVP stuff. The activation however (in
particular the usage of IScreenObjectRegistry) looks really interesting.
Take a look for yourself: [sourcecode language="csharp"] public void
Activate(IScreenObjectRegistry screenObjects) { screenObjects
.Action("Run") .Bind(ModifierKeys.Control, Key.D1)
.To(\_presenter.RunCommand).Icon = Icon.Run; } [/sourcecode]
IScreenObjectRegistry will be inspected in a future post. The next post
though, will take a closer look at the ScreenCollection. So, if you're
eager to learn more about the diamonds and jewels Jeremy has created in
StoryTellers trunk (like I am) rejoin me for the next post when it's
time to go diving again . . .
