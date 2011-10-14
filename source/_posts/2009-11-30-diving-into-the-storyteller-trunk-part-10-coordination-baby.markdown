---
author: BjRo
date: '2009-11-30 10:13:22'
layout: post
slug: diving-into-the-storyteller-trunk-part-10-coordination-baby
status: publish
title: 'Diving into the StoryTeller trunk, Part 10: Coordination Baby!'
wordpress_id: '619'
? ''
: - CompositeApps
  - CompositeApps
  - StoryTeller
  - StoryTeller
  - Composite Apps
  - Composite Apps
  - Design
  - Design
  - StoryTeller
  - StoryTeller
---

So far in this series I've talked extensively about what I consider the
most of the important parts in the StoryTeller UI design. This includes
[Screens](http://www.bjoernrochel.de/2009/08/14/diving-into-the-storyteller-trunk-part-7-screens/),
[the
ScreenCollection](http://www.bjoernrochel.de/2009/08/21/diving-into-the-storyteller-trunk-part-8-the-screencollection/),
[ScreenSubject](http://www.bjoernrochel.de/2009/09/07/diving-into-the-storyteller-trunk-part-9-screensubject-screenfactory/),
[ScreenFactory](http://www.bjoernrochel.de/2009/09/07/diving-into-the-storyteller-trunk-part-9-screensubject-screenfactory/),
[EventAggregation](http://www.bjoernrochel.de/2009/07/20/diving-into-the-storyteller-trunk-part-5-the-eventaggregator/)
and the application of [Convention of
Configuration](http://www.bjoernrochel.de/2009/07/13/diving-into-the-storyteller-trunk-part1-convention-based-registration/)
in general. You could say that we mostly talked about ingredients. Today
I would like to take some additional time in order to show how this is
all assembled into an actual API. Those of you who'veÂ already spend
some time with the StoryTeller codebase too or have watched one of the
many screencasts about the [Screen Activation
Lifecycle](http://www.jeremydmiller.com/ppatterns/Default.aspx?Page=ScreenActivationLifecycle&AspxAutoDetectCookieSupport=1)
probably know what I'm going to show today. Today is all about the
**Screen Conductor**. **Screen Conductor vs. Application Controller**
Before we dive into the actual code, let's take a short break and talk a
little bit about a more high level view on the Screen Conductor and the
role the conductor is fulfilling in an application. Martin Fowler
identified the pattern ApplicationController some years ago as *"[A
centralized point for handling screen navigation and the flow of an
application."](http://martinfowler.com/eaaCatalog/applicationController.html)*
It's kind of a coordination structure which manages / coordinates the
lifecylcle of child screens in an application as well as the lifecycle
of the application shell itself (think about controlled shutdown for
instance). You can think of the ApplicationController as a Facade client
code can call in order to create/activate/deactivate screens in an
application. This Facade defines a nice separation between application
code on the one side and the UI infrastructure on the other side. It
shields away implementation details of how the application is actually
displaying screens (tab style, web style, etc) from the client and also
provides a nice point for handling scenarios like dirty checks on
screens. As an application grows over time, it's a good idea to break
down the ApplicationController into several collaborating classes and
decouple its implementation details from another in order to make the
system more manageable and maintainable. Adding a new screen to the
application for instance should not require a change in one of the UI
infrastructure classes. When breaking down the ApplicationController
into several collaborating classes a good lead is to use the Single
Responsibility Principle in order to identify responsibilities which can
be extracted. That's exactly what Jeremy D. Miller did in his [Screen
Activation
Lifecycle](http://www.jeremydmiller.com/ppatterns/Default.aspx?Page=ScreenActivationLifecycle&AspxAutoDetectCookieSupport=1).
He broke down the ApplicationController pattern into several smaller
responsibilities, the most important beeing

-   the ScreenCollection (which keeps track of all existing screens and
    the one beeing the active screen)
-   the ScreenSubject (which is used to separate identification and
    creation of a screen from the screen itself)
-   Screens (which provide the content beeing displayed and hooks for
    instance for the dirty check when the application closes)
-   and the ScreenConductor.

Jeremy describes the ScreenConductor and its responsibilities as the
following: *"Controls the activation and deactivation lifecycle of the
screens within the application. Depending on the application, the
conductor may be synchronizing the menu state of the shell, attaching
views in the main panel or otherwise, and calling hook methods on the
Presenter's to bootstrap the screen. It may also be just as important to
deactivate a screen when it's made the inactive tab to stop timers. My
first exposure to a Screen Conductor was an insurance application that
was built with web style navigation. Anytime the user moved away from a
screen we needed to check for "dirty" screens to give the user a chance
to deal with unsaved work. On the other hand, we also had to check the
entry into a requested screen to see if we could really open the screen
based on pessimistic locking or permission rules. We pulled our a Layer
SuperType for our Presenters for methods like CanLeave() and CanEnter().
The Screen Conductor would use these methods and others to manage screen
navigation."* To me the ScreenConductor is more or less an OCP-fied
subset of the original ApplicationController pattern, focussing on the
coordination and facade ideas of the original pattern. **A short episode
in the Screen Activation Lifecycle** Let's give our discussion a bit
more detail. So far it was rather abstract. Before looking into the
actual code I would like to walk you through a typical usecase which
depicts how those components actually work together. The example Jeremy
mostly uses for this is "Opening a source code file in Visual Studio" .
I'm lazy, so I'm going to reuse this one. *"Consider you double-click a
file in theÂ Solution Explorer of VS. When you do this for the first
time a new tab displaying the contents of the file will be opened. Doing
the same thing a second time will not open a new tab, but rather focus
the existing tab displaying the contents of the file."* It's actually
easy to translate this story into a more abstract version using the
responsibilities described in this post so far. *"Consider you want to
open a **Screen** via a **ScreenSubject**. When the **ScreenSubject**
detects that no related **Screen** is being displayed to the user, a new
**Screen**will be created by the subject and then added to the
**ScreenCollection**. Doing the same thing a second time will not open
up a **Screen**, but rather activate the existing **SCREEN**, because
the **ScreenSubject**detected that the **Screen**is already open."* The
interesting sidenode in this design is that from a client code
perspective there is no difference between opening up a screen and
activating a screen. Really nice . . . **Usecase: Opening a Screen** Now
that you're familiar with the first scenario, time to show some code.
I've shown parts of this before in the previous post (Sorry for the
duplication), but added some bits in order to illustrate this example.
From the outside world a call to the ScreenConductor for this usecase
might look like this. [sourcecode language="csharp"] var subject = new
CSharpFileSubject(@"C:\\end\\of\\the\\world.cs");
screenConductor.OpenScreen(subject); [/sourcecode] Notice that all data
needed for creating the actual Screen will be passed in with the
concrete ScreenSubject implementation. [sourcecode language="csharp"]
public class CSharpFileSubject : IScreenSubject { private \_fileName;
public CSharpFileSubject(string fileName) { \_fileName = fileName;}
public bool Matches(IScreen screen) { return screen is SourceCodeScreen
&& string.Equals((SourceCodeScreen)screen.FileName, \_fileName)); }
public IScreen CreateScreen(IScreenFactory screenFactory) { var screen
=Â screenFactory.Build(); screen.File = \_fileName; return screen; } }
[/sourcecode] This is not quite the code I would write for a real
system, but I think you get the point. Two methods need to be
implemented for the IScreenSubject interface. This is bool
Matches(IScreen) which identifies a related screen and IScreen
CreateScreen(IScreenFactory) which is used to create the screens. I
really like this kind of API design since it gives you all sorts of
extension points without the need to open up the actual infrastructure.
Want to show a WaitCursor while you create the Screen? Go ahead. Want to
do some loading before the screen is opened? Here's the place to do it .
. . Anyway, the ScreenConductors side of things looks like this.
[sourcecode language="csharp"] public virtual void
OpenScreen(IScreenSubject subject) { if
(subject.Matches(\_screens.Active)) { return; } IScreen screen =
findScreenMatchingSubject(subject); if (screen == null) { screen =
createNewActiveScreen(subject); } else { activate(screen); }
\_screens.Show(screen); } [/sourcecode] Pretty slick, isn't it? The
whole code is really dense. Most of the methods involved are not more
than 5 lines long. Finding the related screen for instance is just a
matter of a LINQ-Query on the ScreenCollection using the Matches-method
as its predicate. [sourcecode language="csharp"] private IScreen
findScreenMatchingSubject(IScreenSubject subject) { return
\_screens.AllScreens.FirstOrDefault(subject.Matches); } [/sourcecode]
Creation of the target screen on the other hand is just a matter of
handing the ScreenFactory (which is actually just a facade to the
IoC-Container of choice) to the subject, activating the created Screen
and adding it to the ScreenCollection. [sourcecode language="csharp"]
private IScreen createNewActiveScreen(IScreenSubject subject) { IScreen
screen = subject.CreateScreen(\_factory); activate(screen);
\_screens.Add(screen); return screen; } [/sourcecode] The last missing
piece here is the actual activation of the Screen. [sourcecode
language="csharp"] private void activate(IScreen screen) {
\_shellService.ActivateScreen(screen); } [/sourcecode] This is delegated
to the so called IShellService. You might ask yourself why this
particular dependency exists (at least I did). The main purpose of this
service is mostly the topic of registering Commands and filling up
option panes related to the current Screen. This will be a post on its
own, so don't be mad at me, when I don't cover it today. Instead I would
like to take a look at another common use case: **Usecase: Closing a
Screen** Now that we've seen how a Screen gets opened, let's take a look
at the other side of the coin, at how it's closed. [sourcecode
language="csharp"] public virtual void Close(IScreen screen) { if
(removeScreen(screen)) { activateCurrentScreen(); } } [/sourcecode] Most
of the handling is in the removeScreen-method (btw, where does this
convention of having all private methods beeing camel-cased come from?
Is this some Java-exposure leaking through? ;-)) [sourcecode
language="csharp"] private bool removeScreen(IScreen screen) { if
(!screen.CanClose()) return false; \_events.RemoveListener(screen);
\_screens.Remove(screen); \_shellService.ClearTransient(); return true;
} [/sourcecode] It delegates the decision whether a screen can be closed
to the screen and in case it can be closed, it removes the screen from
the EventAggregator(\_events), from the ScreenCollection (\_screens) and
clears its Command-registration (\_shellService.ClearTransient()),
before it activates the next screen becoming visible (in case there is
one). [sourcecode language="csharp"] private void
activateCurrentScreen() { IScreen screen = \_screens.Active; if (screen
!= null) { activate(screen); } } [/sourcecode] **Usecase: App shutdown
coordination** There is another common usecase implemented by the
ScreenConductor I would like to show you. This is how the whole app
shutdown is coordinated. Prerequesites for this: Instances interested in
beeing notified when the user tries to shut the application down, need
to a) implement the ***IClosable***interface and b) be registered at the
***EventAggregator***. The latter is done automatically for Screens by
the ScreenConductor. [sourcecode language="csharp"] public interface
ICloseable { void AddCanCloseMessages(CloseToken token); void
PerformShutdown(); } [/sourcecode] The IClosable interface just consists
of two methods. void AddCanCloseMessage(CloseToken) is called in order
to get feedback from listeners whether the application is allowed to be
shutdown. You can think of CloseToken as a more or less extended version
of CancelEventArgs. [sourcecode language="csharp"] public class
CloseToken { private readonly List \_messages = new List(); public
string[] Messages { get { return \_messages.ToArray(); } } public void
AddMessage(string message) { \_messages.Add(message); } } [/sourcecode]
The following code piece is hooked into the Closing - event of
StoryTellers main window (the shell). It heavily leverages the delegate
based eventing of StoryTellers EventBroker in order to interact with all
interested listeners. [sourcecode language="csharp"] public bool
CanClose() { var token = new CloseToken(); \_events.SendMessage(x =\>
x.AddCanCloseMessages(token)); bool returnValue = true; if
(token.Messages.Length \> 0) { string userMessage = string.Join("\\n",
token.Messages); returnValue = \_messageBox.AskUser(CAN\_CLOSE\_TITLE,
userMessage); } if (returnValue) { \_events.SendMessage(x =\>
x.PerformShutdown()); } return returnValue; } [/sourcecode] One remark
to the CanClose() code: \_messageBox is just a small wrapper abstraction
in order to make user interaction via message prompts testable. There's
nothing really fancy behind that. I really like the way the app shutdown
is implemented. In fact we've added something very similar in my current
project. However, I'm not so sure when it comes to the question whether
this particular code piece should be part of the ScreenConductor. You
could argue that this method has only very limited cohesion with the
rest of the ScreenConductors methods. In fact most of the stuff the
ScreenConductor interacts with (ScreenCollection, Screens,
ScreenFactory, ScreenSubject) isn't touched in this method. Besides
that, it's code that client application code normally IMHO doesn't need
to or even should call. In our current app we've extracted this
responsibillity into a separate class called the
ApplicationShutdownCoordinator because of that. **Some more impressions
on StoryTellers ScreenConductor** The exposed API of the ScreenConductor
is pretty small, actually only 6 "core" methods and some overloads.Â
Most of the API really shines. However, besides the already mentioned
CanClose() functionality, there is another functionality which in my
opinion should not be in the ScreenConductor. Can you spot it?
[![image](http://www.bjoernrochel.de/wp-content/uploads/2009/11/screenconductorinterface1.jpg)](http://www.bjoernrochel.de/wp-content/uploads/2009/11/screenconductorinterface1.jpg)
LoadHierarchy(Func<Hierarchy\>)) looks a bit misplaced to me because it
seems to work on a different abstraction level than the rest of the
methods. It looks very application specific, while the rest of the
StoryTeller APIs look very general purpose (independant from the fact
whether Jeremy actually wanted to achieve this or this being just the
result of applying good design practices). Same applies to one of the
Messages / Events the ScreenConductor is registered for at the
EventBroker, namely DeleteTestMessage. I don't think it should be
directly handled in the ScreenConductor.
[![image](http://www.bjoernrochel.de/wp-content/uploads/2009/11/screenconductorhandlers.jpg)](http://www.bjoernrochel.de/wp-content/uploads/2009/11/screenconductorhandlers.jpg)
A static code analysis might indicate that the ScreenConductor has too
many dependencies. In fact there're 7 direct dependencies injected into
the constructor,

-   IEventAggregator
-   IScreenCollection
-   IScreenFactory
-   IApplicationShell
-   IShellService
-   IScreenObjectLocator
-   IMessageCreator

6 transient dependencies (method parameters or local scope),

-   IScreen
-   IScreenSubject
-   CloseToken
-   UserScreenActivation
-   OpenItemMessage
-   DeleteTestMessage

and 3 Message interests

-   UserscreenActivation
-   OpenItemMessage
-   DeleteTestMessage

in the ScreenConductor class. Sounds pretty heavy and like a refactoring
candidate at first. However, as I mentioned earlier, the ScreenConductor
is mostly a Facade with some additional coordination logic in it. When I
say "some additional coordination logic" I mean this literally.
**ScreenConductor has just round about 250 LOC**. I'm totally ok with
this. It certainly has some potential for optimization of the
dependencies (IScreenObjectLocator seems to be at least partially
obsolete, IApplicationShell and IShellService could be merged I guess),
but even without that I consider it a really good example of strong
extensible design forÂ composite desktop apps. For me personally the
ScreenConductor fills a really important gap in the p&p composite app
guidance (be it CAB / SCSF or PRISM). I always had the feeling that I'm
missing something there, but was unable to point out exactly what I've
been missing. This feeling mostly came up when I added some screen
activation or screen creation logic in places that didn't felt right.
Now I know why. Interestingly others [observed the need for something
similar as
well](http://neverindoubtnet.blogspot.com/2009/05/birth-and-death-of-m-v-vm-triads.html).
Having a ScreenConductor in your application makes IMHO the whole UI
infrastructure a lot more approchable and easier to understand. **Some
final thoughts** I left the rest of the ScreenConductors code out of
this post intentionally, because if there's one thing I'd like you to
take from this post or even the complete series is that StoryTeller is a
really good learning resource. I really value, what I've learned from
the Dovetail guys while inspecting the code. I wish I had done this
earlier. Good design matters. If you're looking for a place to learn
more about it, the [StoryTeller
codebase](http://storyteller.tigris.org/source/browse/storyteller/)
might just be the place for you. See you next time, when we take some
time to dig into the command structure of StoryTeller . . .
