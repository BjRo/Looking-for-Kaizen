---
author: BjRo
date: '2009-09-07 09:01:19'
layout: post
slug: diving-into-the-storyteller-trunk-part-9-screensubject-screenfactory
status: publish
title: 'Diving into the StoryTeller trunk, Part 9: ScreenSubject & ScreenFactory'
wordpress_id: '544'
comments: true
footer: true
categories: [dotnet, StoryTeller]
---

Hello back again on my little exploration of the UserInterface
implementation of Jeremy Millers StoryTeller. I'd like to start today
with a little excuse (oh my). Although I said last time that the current
post would be focused on the `ScreenConductor`, I decided to delay that at
least for one post in the series in order to add some content related to
what Jeremy calls `ScreenSubject` and `ScreenFactory`. I consider them to be
fairly simple but yet really powerful pattern which can help you a lot
to structure your UI layer, especially the fine line of the UI layer
where the UI infrastructure meets the common application code. It's also
a very good example of applying the Open Closed Principle.

The common use case for the ScreenSubject
--------------------------------------------------

Lets first start with a little description of the usage of the two
patterns in StoryTeller. When application code wants to open a new
screen in StoryTeller it'll probably use one of the `OpenScreen` overloads
on the `IScreenConductor` facade in order to do that. 

``` csharp Part of the IScreenConductor interface
public interface IScreenConductor 
{ 
  void OpenScreen(IScreenSubject subject); 
  void OpenScreen() where T: IScreenSubject; 
} 
```

The common use case for the `ScreenSubject` can be easily depicted using a tool we all know quite
well, Visual Studio. Think about it: What happens when you click onto a
source code file in the Source Code Explorer for the first time? Well, a
new tab is created displaying the content of the file. However, if you
click the item in the Source Control Explorer the second time, the
previously created tab gets activated and NO NEW TAB IS CREATED.

How is this implemented
--------------------------------------------------

Let's take a look at how this behavior is implemented in StoryTeller.
The following code snippet shows a very small part of the
`ScreenConductor`. I've inline some comments in order to make it more
visible what is going on there. 

``` csharp The OpenScreen method 

public virtual void OpenScreen(IScreenSubject subject) 
{ 
  //_screens is of type IScreenCollection 
  if (subject.Matches(_screens.Active)) 
  { 
    return; 
  }
  
  //This simply makes a LINQ-lookup on the ScreenCollection 
  //using ScreenSubject.Matches as a predicate 
  IScreen screen = findScreenMatchingSubject(subject); 

  if (screen == null) 
  { 
    //This passes the global IScreenFactory into the 
    //ScreenSubjects CreateScreen method in order to create 
    //the screen. 
    screen = createNewActiveScreen(subject); 
  }
  else 
  { 
    activate(screen); 
  }
  
  _screens.Show(screen); 
}
```
The `IScreenSubject` abstraction plays a quite important role in this use case. The interface defines
only two methods matching the responsibilities of the ScreenSubject

``` csharp The IScreenSubject interface
public interface IScreenSubject 
{ 
  bool Matches(IScreen screen); 
  IScreen CreateScreen(IScreenFactory factory); 
}
``` 
As we saw in the `ScreenConductor` snippet the `Matches`
method is used as a predicate in order to find the related screen. The
`CreateScreen` method isn't directly shown in the snippet, but it's not
that complicated. It's responsible for coordinating the creation of a
screen. When I say coordination I'm referring to the fact that the
actual screen creation is the responsibility of the `IScreenFactory`
(which is just a simple wrapper around StructureMap). 

``` csharp The IScreenFactory interface 
public interface IScreenFactory 
{ 
  T Build<T>() where T : IScreen; 
  IScreen<T> Build<T>(T subject); 
} 
```

With this design in place we have a very nice extension point in place to do all kinds of
things around the screen creation. Want to do some deferred data loading
before the screen is shown? That's your place. Maybe you want to show
some progress indicator while doing this. Guess what, that's your place
to do this. And the best of it: The screen doesn't have to know anything
of this, you can free him of this kind of logic. There're some base
classes which provide some base implementation for different use cases
in StoryTeller. I'm only going to show one of them, the
`ScreenSubject<T>`. This class adds a bit generics on top of the
ScreenSubject (in order to allow auto-registration using StructureMaps
convention over configuration features). 

``` csharp ScreenSubject<T> 
// Marker interface 
public interface IScreenSubject<T> : IScreenSubject { }

public class ScreenSubject<T> : IScreenSubject<T>
{ 
  private readonly T _subject; 
  
  public ScreenSubject(T subject) 
  { 
    _subject = subject; 
  }
  
  #region IScreenSubject Members 
  
  public bool Matches(IScreen screen) 
  {
    var specific = screen as IScreen; 
    
    if (specific == null) 
      return false;

    return specific.Subject.Equals(_subject); 
  }
  
  public IScreen CreateScreen(IScreenFactory factory) 
  { 
    return factory.Build(_subject);
  } 
  
  #endregion 
  
  public bool Equals(ScreenSubject<T> other) 
  { 
    if (ReferenceEquals(null, other)) 
      return false; 
    
    if (ReferenceEquals(this, other)) 
      return true; 
    
    return Equals(other._subject, _subject); 
  } 
  
  public override bool Equals(object obj) 
  {
    if (ReferenceEquals(null, obj))
      return false; 
    
    if (ReferenceEquals(this, obj)) 
      return true; 
    
    if (obj.GetType() != typeof (ScreenSubject<T>)) 
      return false; 
      
    return Equals((ScreenSubject<T>) obj); 
  } 
  
  public override int GetHashCode() 
  {
    return _subject.GetHashCode(); 
  } 
}
``` 
The basic idea used in this implementation of `IScreenSubject` is that a `ScreenSubject` is related
to a single data instance. Coming back to the Visual Studio example,
this could have been represented as something like
`ScreenSubject<SourceCodeFile>`. Really interesting . . . 

The last code snippet for today I'd like to show is how the `ScreenFactory` is actually
implemented. As usual really short, not very much code. 

``` csharp The ScreenFactory
public class ScreenFactory : IScreenFactory 
{ 
  private readonly IContainer _container; 
  
  public ScreenFactory(IContainer container) 
  { 
    _container = container; 
  } 
  
  #region IScreenFactory Members

  public SCREEN Build<SCREEN>() where SCREEN : IScreen 
  { 
    return _container.GetInstance<SCREEN>(); 
  } 
  
  public IScreen<T> Build(T subject) 
  { 
    return _container.With(subject).GetInstance<T>(); 
  } 
  
  #endregion 
} 
```
I really like the way how StructureMap allows injecting transient
parameters in the resolution process . . .

Closing thoughts
-----------------------------------------------------------

I'm honest with you. I consider `ScreenSubject` to be one of the most
valuable patterns I've learned so far while playing with the StoryTeller
sources. It provides such a nice extension point for screen
initialization. I think it's one of those patterns you don't know how
much you miss it until you see it for the first time and recognize how
much it could have helped you in the past. At least that was my
reaction. In the past I've put a lot of the functionality which resides
in StoryTeller in `ScreenSubject` implementations on my screens which
polluted my screens with a lot of initialization code and sometimes
(especially when you have high network latency) doesn't even really look
good (I bet you know what I'm talking about, don't you? I bet a lot of
you have seen the frozen screen, too). The `ScreenSubject` pattern was
introduced to my project last week and what can I say: I'm pretty happy
to have it in our application ;-)
