---
author: BjRo
date: '2009-07-17 22:36:55'
layout: post
slug: diving-into-the-storyteller-trunk-part-4-registration-of-generics
status: publish
title: 'Diving into the StoryTeller trunk, Part 4: Registration of Generics'
wordpress_id: '422'
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

I really like the way StructureMap automates the container registration.
Part 1 already showed a lot of the convention based container
registration mechanism. Today I would like to touch an aspect of
registration which doesn't really fit under the term "convention over
configuration", but is a really cool functionality non the less. For
this post I would like to take a look at what you can do with generic
types in StructureMap (taking you of course through some code parts of
StoryTeller).

Let's start with a look at the IScreenSubject interface in the
StoryTeller trunk. This interface plays a very important role in the UI
layer of StoryTeller. Its basic responsibility is the creation and the
identification of a single screen. The whole topic will be part of later
posts, so don't be mad with me, if I don't go into full detail here.
What matters for the context of this post is that there is also an
IScreenSubject<T\> marker interface. [code language="csharp"] public
interface IScreenSubject { bool Matches(IScreen screen); IScreen
CreateScreen(); } //Marker interface public interface IScreenSubject :
IScreenSubject { } [/code] If you take a look at StoryTellers
UserInterfaceRegistry class, the class containing all the StructureMap
configuration, you'll notice a method on the configuration expression
with the name "ConnectImplementationsToTypesClosing" which takes a
single open generic type as the parameter (The IScreenSubject<\> type in
the following snippet). [code language="csharp"] public class
UserInterfaceRegistry : Registry { public UserInterfaceRegistry() { . .
. Scan(x =\> { x.TheCallingAssembly(); x.WithDefaultConventions();
x.ConnectImplementationsToTypesClosing(typeof(IScreenSubject<\>)); }); .
. . } } } [/code] For those of you who haven't heard of open and closed
generic types: An open generic type is a generic type which doesn't have
his type parameters specified (for instance typeof(IListener<\>)), while
a closed generic type is a generic type which has his type parameters
specified (for example typeof(IListener<string\>)).

So what's the deal with those types? StoryTeller has several
implementations of the IScreenSubject<T\> interface. The following
snippet shows one of them. It has been a bit simplified for this post.
What's important here is that because this type closes the
IScreenSubject<T\> type with the TestScreen type, it is automatically
registered in the container if it resides in one of the assemblies
scanned by StructureMap. [code language="csharp"] public class
TestScreenSubject : IScreenSubject { private readonly IContainer
\_container; public ScreenSubject(IContainer container) { \_container =
container; } \#region IScreenSubject Members public bool Matches(IScreen
screen) { return screen is TestScreen; } public IScreen CreateScreen() {
return \_container.GetInstance(); } \#endregion } [/code] Client code
can access this instance after registration via [code language="csharp"]
//<-- this will give you an TestScreenSubject instance
container.GetInstance\>(); [/code] What we've seen so far is how
instances can be automatically registered for closed generic interfaces
by StructureMap. However if we take a look at the TestScreenSubject
class, isn't there something which can be generalized and reused? In
fact you can find the ScreenSubject<SCREEN\> class in the StoryTeller
which looks like a generalized version of it. [code language="csharp"]
public class ScreenSubject : IScreenSubject where SCREEN : IScreen {
private readonly IContainer \_container; public ScreenSubject(IContainer
container) { \_container = container; } \#region IScreenSubject Members
public bool Matches(IScreen screen) { return screen is SCREEN; } public
IScreen CreateScreen() { return \_container.GetInstance(); } \#endregion
} [/code] This class however isn't automatically picked up by auto
registration or one of the conventions. Besides that, notice that this
is not an abstract class. So, using it as a base class in order to fit
in the ConnectImplementationsToTypesClosing scheme is probably not
really the main usage scenario for this class (although you could of
course do it). What we can do instead is register this class as the
default implementation for the IScreenSubject<T\> interface. (SIDENOTE:
StoryTeller doesn't really use this so the rest of the post is more or
less a StructureMap feature demo ;-)) [code language="csharp"] public
class UserInterfaceRegistry : Registry { public UserInterfaceRegistry()
{ . . . For(typeof(
IScreenSubject<\>)).TheDefaultIsConcreteType(typeof(ScreenSubject<\>));
. . . } } [/code] Looks strange at first, but it's a really handy thing
once you've got used to it. Here's an example how the container behaves
after both TestScreenSubject (implicitly by ConnectAllTypeClosing) and
ScreenSubject<T\> (explicitly by For...) have been registered. [code
language="csharp"] //This will return an instance of the type
TestScreenSubject container.GetInstance\>(); //This will return an
instance of the ScreenSubject container.GetInstance\>(); [/code] The
container basically does this: If the requested closed generic type is
directly implemented by a registered type (TestScreenSubject here) this
type is resolved. On the other hand when the requested generic type is
not directly implemented by any registered type, but an open generic
type implementing the open version of the interface is registered
(ScreenSubject<\> here) the container will close that type and return an
instance for it. AFAIK this is called "generic specialization". A simple
example where generic specialization is really handy: You want to
implement validation. Therefore you create an IValidator<T\> interface
and an standard implementation Validator<T\> for it which validates
static rules based on attributes (string length, not null, etc). For one
particular type you realize that this is not sufficient, because maybe
you need some sort of catalog in order to validate correctly. With
generic specialization you're able to introduce this special case for
the particular type very, very easily. Just follow the steps described
in this post. From a clients perspective nothing changes . . .

**Conclusion**

Generic specialization is one of the things I really love when using an
IoC. It's one of those areas where IoC imho really shines. To be fair,
this ability is not StructureMap exclusive. Most of the other containers
have it, too. However, I'm amazed how much fluff (or ceremony as Jeremy
likes to say) can be cut from registration by StructureMap . . .
