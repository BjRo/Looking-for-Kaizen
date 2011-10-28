---
author: BjRo
date: '2009-07-20 21:19:11'
layout: post
slug: diving-into-the-storyteller-trunk-part-5-the-eventaggregator
status: publish
title: 'Diving into the StoryTeller trunk, Part 5: The EventAggregator'
wordpress_id: '439'
comments: true
footer: true
categories: [dotnet, StoryTeller, StructureMap]
---

I've spend some time with the Pub / Sub topic on my own in the past. Although I
still like my own implementation, even a year after I've originally
written it (yes, rare but sometimes that happens), I really like how
Jeremy implemented it. The `EventAggregator` in StoryTeller is one of
those examples of how much you can achieve with only a few lines of
code. So let's go diving again ;-)

A type who is interested in recieving messages from the EventAggregator
in StoryTeller has to implement the `IListener<T>` interface where T
specifies the concrete message / event. A container extension is used
for automatic registration of instances at the `EventAggregator` after
instances have been created in the container (more on this later in the
post).

``` csharp The listener interface 
public interface IListener<T> 
{ 
  void Handle(T message); 
}
```
The interface to the `EventAggregator` looks like this. 
``` csharp The EventAggregator interface 
public interface IEventAggregator 
{ 
  void SendMessage<T>(Action<T> action) where T : class; 
  void SendMessage<T>(T message);
  void AddListener(object listener); 
  void RemoveListener(object listener);
} 
```

Most of the interface looks familiar to me, except the
`SendMessage<T>(Action<T> action)` method. The `EventAggregator`
implementation in StoryTeller adds a interesting feature to the topic:
Using delegates instead of explicit event classes. One of the things
Jeremy mentioned in his NDC "Presentation Patterns" talk is that
sometimes creating event classes for events felt a bit tedious to him,
especially when those events only have signal character and don't carry
any data with them around. IIRIC the varation with delegates instead of
event classes implemented in StoryTeller came up in discussion with
Glenn Block and the Prism team. However it didn't make it into Prism in
the end. See the difference in usage for yourself: 

``` csharp Classic vs. delegate based messaging
//Using message objects 
aggregator.SendMessage(new ScreenClosingMessage(screen)); 
//Using delegates as messages
aggregator.SendMessage<IWantToKnowWhenAScreenClosed>(x => x.ScreenHasClosed(screen)); 
```

Below is the code for the `EventAggregator`. There are some interesting things to notice.

-   First of all, the `EventBroker` doesn't know about subscriptions for a
    particular type. It only knows listener objects. Compatible
    listeners are found on the fly when the event / message is published
    by iterating over all known listener objects and calling the CallOn
    extension method. I'll spare the code for this extension method
    because all it does is executing an `Action<T>` only when an object
    can be cast to the type specified by `T`.
-   Automatic thread-synchronization to the main-thread is applied by
    using the `SynchronizationContext` class. Imho, one of the gems in the
    .NET 2.0 release that more people should be aware of. I think this
    class is a really great feature for freeing client code from dealing
    with callback synchronization issues. Just let the framework handle
    the `InvokeRequired` stuff for you. No one likes to write that stuff
    anyway.
-   Jeremy likes it functional ;-). I think this is an interesting
    example how C# 3.0 code can actually differ from an 1.0
    implementation. The shown code is really, really dense and focussed
    by using a lot of the C# 2.0 and 3.0 features like lamda
    expressions, extension methods and of course generics. Personally I
    really like this coding style, however a lot of my colleagues don't.
    The debugging story differs a lot from the one using classic if and
    for loops, which isn't such a problem for the test-first or
    test-parallel guys, but I can see where this might feel a bit
    awkward when you've relied on the debugger for most of your
    developing efforts in the past. In my opinion it's just a matter of
    personal taste. Just give it a try and make your own opinion . . .

``` csharp The EventAggregator as implemented in StoryTeller
public class EventAggregator : IEventAggregator
{ 
  private readonly SynchronizationContext _context; 
  private readonly List<object> _listeners = new List<object>(); 
  private readonly object _locker = new object(); 
  
  public EventAggregator(SynchronizationContext context) 
  {
    _context = context; 
  } 
  
  #region IEventAggregator Members 
  public void SendMessage<T>(Action<T> action) where T : class 
  { 
    sendAction(() => all().Each(x => x.CallOn(action))); 
  }
  
  public void SendMessage<T>(T message) 
  {
    sendAction(() => all().CallOnEach>(x => 
    {
      x.Handle(message); 
    })); 
  } 
  
  public void AddListener(object listener) 
  {
    withinLock(() => 
    { 
        if (_listeners.Contains(listener)) return;

        _listeners.Add(listener); 
    });
  } 
  
  public void RemoveListener(object listener) 
  { 
    withinLock(() => _listeners.Remove(listener)); 
  }

  #endregion 

  public void AddListeners(params object[] listeners) 
  { 
    foreach (object listener in listeners)
    { 
      AddListener(listener); 
    } 
  } 
  
  public bool HasListener(object listener) 
  {
    return _listeners.Contains(listener); 
  } 
  
  public void RemoveAllListeners() 
  {
    _listeners.Clear(); 
  } 

  protected virtual void sendAction(Action action) 
  {
    _context.Send(state => { action(); }, null); 
  } 

  private object[] all() 
  {
    lock (_locker) 
    { 
      return _listeners.ToArray(); 
    } 
  } 
  
  private void withinLock(Action action) 
  { 
    lock(_locker) 
    {
      action(); 
    } 
  } 
}
```

As I said earlier in this post, instances are registered after they've been
created by the container. The functionality for this is provided by a
TypeInterceptor class. This class is part of the StructureMap API. Once
it has been registered every created instances is passed through this
interceptor after it has been resolved. If the instance is identified as
relevant for the `EventAggregator` it is automatically registered. 

``` csharp Integrating the EventAggregator into StructureMap
public class EventAggregatorInterceptor : TypeInterceptor 
{ 
  #region TypeInterceptor Members 
  
  public object Process(object target, IContext context) 
  { 
    context.GetInstance<IEventAggregator>().AddListener(target); 
    return target; 
  } 
  
  public bool MatchesType(Type type) 
  { 
    return type.ImplementsInterfaceTemplate(typeof(IListener<>)) || 
      type.CanBeCastTo(typeof (ITestListener)) ||
      type.CanBeCastTo(typeof (ICloseable)); 
  } 
  
  #endregion 
} 
```

Conclusion
---------------

EventAggregation is one of the standard patterns in modern enterprise
applications. I like the elegant way how Jeremy implemented this.
However having spend some time with this in the past, I miss a
functional part in his implementation: Type based subscriptions. Type
based subscriptions can be really handy when you're implementing
PageFlows or state-ful MessageHandlers. Once a message is recieved the
type is resolved by the container and the related handler method is
called on the newly created type. I had them in my last application and
liked them a lot. Maybe StoryTeller goes alternative routes to achive a
similar effect. We'll see as we proceed in the code . . .
