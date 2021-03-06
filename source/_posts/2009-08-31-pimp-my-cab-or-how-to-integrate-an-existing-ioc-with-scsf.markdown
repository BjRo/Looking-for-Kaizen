---
author: BjRo
date: '2009-08-31 21:14:53'
layout: post
slug: pimp-my-cab-or-how-to-integrate-an-existing-ioc-with-scsf
status: publish
title: Pimp my CAB, or how to integrate an existing IoC with SCSF
wordpress_id: '531'
comments: true
footer: true
categories: [dotnet]
---

A LITTLE WARNING: This post goes pretty deep into the CAB framework
without examining the CAB basics. If you're unfamiliar with CAB or SCSF
this post is probably not going to be very handy for you . . . 

My current project uses the Smart Client Software Factory which is build on
top of the Composite UI Application Block from Microsofts Patterns &
Practices department. SCSF is an organizational standard at my current
client and we're reusing some components of earlier projects (Large
Parts of the Shell, Changetracking model etc.) 

CAB is build around a very simple Dependency Injection machinery called the `ObjectBuilder`. I
consider having the `ObjectBuilder` a good thing, compared to having no
Dependency Injection at all. However if you've ever worked with any
other IoC be it StructureMap, Unity, Windsor, NInject or some other
container, you'll recognize pretty fast some limitations. Its dependency
injection mechanism

-   can't really be used without attributes.
-   doesn't separate registration and creation very well, which often
    leads to ordering problems.
-   can't close open generic types. If you've ever used generic
    specialization you're going to miss this.
-   is pretty tightly coupled to the concept of `WorkItems` inside CAB.

The last point is actually the real pain point for me. The whole
`WorkItem` API is way to general purpose and generic (meaning string
based!!!) in many parts and actually not the kind of concept I would
like to be a central piece of my application design. It's not intuitive
to work with it and imho doesn't fall into the pit of success at all.

Interestingly when you compare PRISM (which was also build by P&P about
two years later) to CAB you're going to recognize that the concept of
WorkItems is completely missing in PRISM. Maybe I'm not the only one who
feels that way. Our team decided very early that the whole contact area
of our application to the CAB framework should be limited to the
presentation layer. We wanted to use a fully fledged IoC on the lower
layers. This lead to an intersting challenge: How to integrate those two
pipelines? My initial thought was to replace the `CreationStrategy` used
in CABs `Builder` class with something that reaches into our main
container. This turned out not to be the best choice since a lot of CABs
internal structure kind of relates to the standard behavior. I got
something working for about half of the use cases, but it didn't really
feel good. 

You know the best ideas come up when you stand under the
shower. At least this happened yesterday. Actually integrating those two
things is pretty straight forward. I just needed to approach the problem
differently. CAB is build around attributes. A typical CAB service might
look like this. 

``` csharp A service using CAB
public class NavigationService 
{ 
  public NavigationService([ServiceDependency] IShell shell) 
  { 
  } 
} 
```

The `ServiceDependencyAttribute` tells the
`ObjectBuilder` that it should get the dependency from the collection of
services associated with the related `WorkItem` used to create the class.
The interesting part is that this isn't a marker attribute. It's a fully
fledged extension point to which the `ObjectBuilder` delegates the
essential work of resolving an instance.

> Here's the deal: You can write a custom tailored attribute which is
called by the ObjectBuilder but uses your main IoC in order to resolve
the dependency

The implementation of this is actually pretty easy. Here are the steps
you need to implement.

1. Create a Static Gateway into your container
--------------------------------------------------

Attributes are by their nature kind of static and created by the
framework. In order to be able to call into my container from an
attribute I created a static class which holds a reference to my
container (You can of course also use the P&P CommonServiceLocator for
this). 
``` csharp Create a static gateway into your container
public static class Container 
{
  private static IContainer _container; 

  public static void SetContainer(IContainer container) 
  { 
    _container = container; 
  } 
  
  public static void object Resolve(Type type) 
  { 
    return _container.Resolve(type); 
  } 
} 
```

2. Create an attribute deriving from ParameterAttribute
--------------------------------------------------

The responsibility of `ParameterAttributes` in the `ObjectBuilder` is pretty
limited. All they have to do is to create an implementation of the
`IParameter` interface which will than be used to do the actual resolving.
If you're wondering what the membertype is, that's the type of the
parameter marked with the attribute (in the example code above this
would be `IShell`). The `CreateParameter` method will automatically be
called by the `ObjectBuilder` during the creation process. 

``` csharp Creating a custom ParameterAttribute
public class ContainerDependencyAttribute : ParameterAttribute 
{ 
  public override IParameter CreateParameter(Type memberType) 
  { 
    return new ContainerParameter(memberType); 
  }
}
```

3. Create an implementation of IParameter which calls into your static gateway
-------------------------------------------------------------------------------

The `IParameter` interface defines two methods `GetParameterType` and `GetValue`.

``` csharp The IParameter interface
public interface IParameter 
{
  Type GetParameterType(IBuilderContext buildContext); 
  object Getvalue(IBuilderContext buildContext); 
} 
```

We simply implement the first one with returning the member type and the the
second one with a call into our Gateway. 

``` csharp A parameter that calls into our container
public class ContainerParameter : IParameter 
{ 
  private Type _typeToResolve; 
  
  public ContainerParameter(Type typeToResolve) 
  {
    _typeToResolve = typeToResolve; 
  } 
  
  public Type GetParameterType(IBuilderContext buildContext) 
  { 
    return _typeToResolve;
  } 
  
  public object Getvalue(IBuilderContext buildContext)
  { 
    return Container.Resolve(_typeToResolve); 
  } 
}
```

Here is an example how it is used
-----------------------------------

``` csharp Using the new attribute
public class SomePresenter 
{ 
  public SomePresenter(
    [ServiceDependency] INavigationService navigationService,
    [ContainerDependency] ISomeService someService)
  {
  } 
} 
```

At least for us, this works like a charm. What I like about the solution is
that it plays nicely by the rules of the CAB framework and doesn't fight
the framework design, but still enables us to use the framework in a way
we want to use it. The interesting aspect in this approach is that
you're now able to haved mixed dependencies where one part is resolved
using the surrounding CAB `WorkItem` and the other part is resolved using
your container of choice. The whole attribute usage is limited to the
presentation layer while the rest of the application can take advantage
of fully fledged dependency injection without attribute, with generic
specicialization and dynamic proxy generation, just to name a few
options.
