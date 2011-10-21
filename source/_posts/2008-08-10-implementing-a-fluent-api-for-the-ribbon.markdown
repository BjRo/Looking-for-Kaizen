---
author: BjRo
date: '2008-08-10 20:07:44'
layout: post
slug: implementing-a-fluent-api-for-the-ribbon
status: publish
title: Implementing a fluent API for the ribbon
wordpress_id: '21'
comments: true
footer: true
categories: [dotnet, sw-design]
---

For the last two weeks I've been engaged in implementing an internal Domain Specific Language (DSL) for dealing with the ribbon in a Windows
Forms composite client. For those of you who haven't heard of the ribbon before, it's the [new user interface](http://en.wikipedia.org/wiki/Ribbon_(computing)) microsoft introduced with MS Office 2007.
Those two weeks have really been interesting, mostly because this was the first time I actually tried to build a large internal DSL. 

In this post I would like to talk a bit about internal dsls, the implementation of the ribbon dsl and what I learned from those two weeks . . . 
<!--more-->

So, what is actually an internal dsl?
---------------------------------------
So what is an internal dsl actually? An internal dsl is basically just another style of an API, which follows a more language-oriented approach. 
Instead of following the classic [CommandQuerySeparation](http://martinfowler.com/bliki/CommandQuerySeparation.html) - principle, it encourages a more fluent style of programming, which
when read out loud by a reader is intent revealing enough to understand what the code basically does. 
Martin Fowler and Eric Evans coined the term fluent API to describe this behavior, which I will use too in the rest of this post. 
Source code and pictures usally say more than a hundred words, so here a some examples for fluent APIs.

``` csharp Container configuration in Castle Windsor 

	container.Register(Component.For<ICommand>()
			.Named(CommandNames.StartSearch)
			.ImplementedBy<SearchCommand>() 
			.LifeStyle.Singleton);
```

``` csharp Assertions with the constraint - API in NUnit
Assert.That("Foo", Is.Not.Null); 
```

``` csharp Fluent Mocking with Rhino.Mocks: 
using (Record()) 
{ 
	Expect.Call(_FormFactory.LoadForm(config))
		.IgnoreArguments() 
		.Return(new DummyForm())
		.Constraints(new ValidFormConfigurationConstraint()); 
} 
```
Did you notice one thing the examples above all have in common? **Yes, they' re all OSS!**
A lot of OSS-projects have embraced fluent APIs in the past or seem to embrace this API style lately. Although they're currently just the
minority of existing APIs out there, it's interesting to watch the emergence of more language-oriented APIs, even in the .NET Framework
core. I think nobody will slap me when I say that Linq can be described as an internal dsl for querying data. You may have guessed it, I like fluent APIs a lot. 
I won't say they are applicable everywhere, but personally I think there are places where they can give you quite a bit advantage in readability and testability
over regular APIs. Especially configuration and specification scenarios are very well suited for fluent apis. 

Possible ingredients of a fluent API
-------------------------------------
###Method chaining 

The basic idea of method-chaining is that you directly use the return value of a method in order to invoke a method
on it and repeat this as long as needed in order to make sense as a complete sentence. The easiest way to achieve this is a class whose
methods all return a this reference. Here's a simplified example of something I've written earlier this year. It's a kind of
specification that describes the details of a form which a form framework should create. Don't worry about the details. This is just a
shortened example. 

``` csharp This is part of the class definition . . .
internal class FormCreationExpression 
{
	public FormCreationExpression(Guid formId) 
	{ 
		_Configuration = new FormConfiguration(formId); 
	} 
	
	public FormCreationExpression WithBinding<T>(T instance) 
	{ 
		_Configuration.AddBinding(instance); 
		return this; 
	} 
}
```
``` csharp . . . combined with a static entry point like this . . .
public static class From 
{
	public static FormCreationExpression Template( Guid formId) 
	{ 
		return new FormCreationExpression(formId); }
	} 
```
``` csharp . . . it can be used like this
IClientForm form = _FormFactory.CreateForm(From.Template(templateId).WithBinding(patient)); 
``` 

One personal note to method chaining: If you're using a mock framework like for instance `Rhino.Mocks` better don't try to mock out a fluent interface. 
Find other ways to test it. So, why am I saying this? Most mocking framework don't have a natural syntax for configuring the expectations on fluent apis (except [`TypeMock`](http://www.typemock.com)). Because of that you have to
configure every call on the chain step by step, which is a) very tedious and b) also results in not well readable tests (which mostly smell, too). 

The form example above is what I mostly do in order to get better testability. I mostly use fluent APIs as builders, which produce something I can easily test / verify
(In the example above it's the configured `FormExpression`). Most of the fluent API's I created used the `Fluent Builder` pattern. 
The basic pattern for `Fluent Builder` can be easily described: Method chaining + an implicit conversion operator for the convertion into the build product.

``` csharp A Fluent Builder
public static implicit operator FormConfiguration(FormExpression expression)
{
	return expression._Configuration; 
}
```

When I was implementing the ribbon fluent API however, I used a variation of a different pattern which is called `Expression Builder`. The idea of the `Expression Builder`
pattern is that the fluent API only is layer on top of a regular API. It serves as a kind of facade to the other api. This was especially useful because I didn't want the ribbon API to be coupled to a particular
vendor implementation. Instead the API uses interfaces and a facade in order to perform actions on the concrete ribbon control. Please have a bit patience, I'll show code soon. 
Read [here](http://martinfowler.com/dslwip/ExpressionBuilder.html) for a bit more on `Expression Builders`. 

###Nested functions 
One problem with fluent APIs implemented only with method chaining is extensibility or reusability.Â A short example. Let's assume we have a typical OO
situation with two products having a lot of properties in common but also some special ones. Let us further assume that we want to build
fluent builders for each of them. One approach is to use a `Fluent Builder` base class and derived builders for each product. When you do
this you have an API in which some of the methods (those implemented by the builder base class) return only a subset of the API (because they
only return an instance of the base class). In order to use the methods of the derived `Fluent Builder` in combination with those of the base
class you have to call the special methods first before continuing with the base class method in the fluent chain. 

You can get around this (look [here](http://sergeyshishkin.spaces.live.com/blog/cns!9F19E53BA9C1D63F!218.entry)) for more informations) with redefinition and the new operator, but imho
it doesn't smell very good. However I haven't found a solution which solves the problem **and** makes me happy. Has anyone found a better
solution? I would like to hear other thoughts on this. With that beeing said, how can extensibility be tackled without sacrificing the language
orientation. That's where `Nested Functions` come into play. The basic idea is that you compose your fluent API out of several independant
parts/ functions. A good example for this is the constraint API that `NUnit` provides. Look at the signature of the `That` method of the `Assert`
class. 

``` csharp NUnits Assert class
public class Assert 
{ 
	public void That(object obj, Constraint constraint)
	{
		//...
	}
} 
```
Doesn't really look fluent first, doesn't it? But combined with a static entrypoint and a derived constraint `NUnit` is able to achive a very nice and well
readable syntax for specifiing tests. 

``` csharp NUnit constraints in Action
Assert.That(obj, Is.Not.Null); 
```
For me this API is just a single piece of beauty. Awesome :-).
You can read more about `Nested Functions` [here](http://martinfowler.com/dslwip/NestedFunction.html).

That's all I' d wanted to show you about fluent APIs in this post. If you're interested in learning more about fluent APIs I would highly
recommend Martin Fowlers [current articles](http://martinfowler.com/dslwip/InternalOverview.html) about DSLs. Although they're work in progress (as part of an upcoming book),
I consider them best resource for learning about dsls available at the moment. Before I'll show bit from the ribbon API I want to give you an
impression what the actual requirements for the API were. 

The basic requirements for the ribbon API
-------------------------------------------

1.  The API should provide benefit in a composite (windows forms)
    architecture, where modules are loosly coupled and UI configuration
    is scattered through several modules. From a product level
    perspective the API should enable very exact (and relative)
    positioning of elements while the load order of modules might
    change.
2.  The interaction with the ribbon should be testable with unit tests.
3.  Consumer code of the API should not be coupled to a particular
    vendor implementation of the ribbon.
4.  Consumer code should be able to configure the ribbon from any
    thread.
5.  Configuration via an external XML - file should be possible
    (although not implemented in the current version).

An internal dsl for the ribbon
-------------------------------

One of my earliest design decisions was to design the ribbon API to be based on the `Command pattern`
internally. The decoupling that was possible with such a design allows a good level of control over the execution of the commands (which is
very important while initializing modules (Requirement 1) ). Besides that commands are a good candidate for testability, because the
configuration of the commands can be tested via unit tests whithout actually having to execute them. Because of that I decided to implement
a little variation of the `Fluent / Expression Builder` topic. Let's look at some code. There are four static entrypoints for creating fluent
(command) builders. 

These are the `CreateNew` class, which creates commands that when executed configure the ribbon UI,

``` csharp Configuring the ribbon layout
CreateNew.Tab.Named(RibbonTabNames.Home)
	.WithCaption(SR.HomeTabCaption)
	.AddGroups(
		CreateNew.Group.Named(RibbonGroupNames.SearchGroup)
			.WithCaption(SR.SearchGroupCaption) .WithVerticalLayout()
			.WithToolsAlignedCentered() 
			.AddTools(
				CreateNew.TextBox.Named(ToolNames.SearchTextBox)
					.RaisingCommandOnReturn(CommandNames.StartSearch),
				CreateNew.Button.Named(ToolNames.SearchButton)
					.WithCaption(SR.SearchButtonCaption) 
					.WithLargeImage(Images.Search_32)
					.WithSmallImage(Images.Search_16)
					.DisplayedAsLargeToolWithCaptionBelow()
					.RaisingCommand(CommandNames.StartSearch))); 
```
the `Enable` and the `Disable` class for creating commands, which enable
or disable elements on the ribbon, 

``` csharp Enabling or disabling a tool
Enable.Tool(ToolNames.SearchButton).If(() => shouldActivate);
```

 the `ChangeVisibilityOf` class for creating commands, which change the visibillity of elements on the ribbon, 
``` csharp Changing the visibility of a tool
ChangeVisibilityOf.Tool(ToolNames.SearchButton).ToInvisible() .If(() => shouldBeInvisible); 
```

and the `Access` class for creating commands, which perform other read or write
operations on elements on the ribbon. 

``` csharp Accessing a tool in the ribbon
Access.TextBox(ToolNames.SearchTextBox).ReadText( text => DisplayText(text) ); 
```

The commands execute against a internal facade for the ribbon. This facade is completely based on
interfaces and can be adapted to different vendor APIs (at least thats the idea :-)). This is the regular API to which I referred when I
talked about `Expression Builder` previously. The next code sample shows the implementation of the `NewTabCommand` for creating new tabs on the
ribbon. 

``` csharp The implementation of the NewTabCommand
internal class NewTabCommand : ShellCommand 
{ 
	public NewTabCommand( RibbonTabConfiguration configuration, IEnumerable groupBuilderCommands) 
	{ 
		Configuration = configuration; 
		GroupBuilderCommands = groupBuilderCommands; 
	} 
	
	internal RibbonTabConfiguration Configuration { get; set; } 
	internal IEnumerable GroupBuilderCommands { get; set; } 
	
	public override void Execute() 
	{
		var tab = GetShell().CreateTab(Configuration); 
		
		foreach (var command in GroupBuilderCommands) 
		{ 
			command.OverrideTabSetting(tab);
			command.Execute(); 
		}
	} 
} 
```

`Commands` are executed with the `ICommandExecutor`. Main responsibility of the service is to allow thread safe access to the ribbon (which runs in the UI thread), so that the
module initialization can run multi-threaded. Is has several overloads for running commands. This is one of them: 

``` csharp Executing a ribbon command
public void ExecuteCommand(Command command) 
{
	Ensure.ArgumentIsNotNull(command, "command"); 
	
	if(command.IsAvailable()) 
	{ 
		_ThreadContextOfMainThread.Send( c => command.Execute(), null); 
	} 
} 
```

To complete the picture I wrote custom assertion to make testing easy. 

``` csharp Testing support
[Test] 
public void Command_with_false_condition_should_not_enable_tool() 
{ 
	var command = Enable.Tool("Foo").If(() => false); 
	Assert.That(command, DoesNotEnable.Tool("Foo")); 
} 
```

Some final thoughts to conclude this post
--------------------------------------------

It's harder than I orignally thought to create large fluent APIs in C#. Especially code reuse and extensibility can be
barriers. C# as a statically typed language is somehow limited here (One more reason to learn more about Ruby and Boo . . .). I'm
particulary don't like reusability through builder inheritance and method redefinition, though I'm doing it because of a lack of options.
Again, does anyone know a way in C# around this? Finally I really like the readability and testability of what I've implemented, although there
is still a lot room for improvements. Feel free to post (positive and negative) thoughts on this or domain specific languages in general.
Read you soon :-)
