---
author: BjRo
date: '2009-07-13 08:26:34'
layout: post
slug: diving-into-the-storyteller-trunk-part1-convention-based-registration
status: publish
title: 'Diving into the StoryTeller trunk, Part 1: Convention based registration'
wordpress_id: '392'
comments: true
footer: true
categories: [dotnet, StoryTeller, StructureMap]
---
Since I've read some bits about Rails I often wondered how "Convention
over Configuration" (CoC) might look like in a .NET environment.
StructureMap was (AFAIK) the first IoC container in the .Net realm which
provided functionality in order to combine conventions with dependency
injection. It's not surprising that StoryTeller relies a lot on
StructureMap and CoC, considering that both tools share the same author.

So let's dive into the StoryTeller trunk and look at how CoC is applied
inside the tool. I'm starting with the Bootstrapper of the application.
The main responsibility of the Bootstrapper (as its name implies) is to
boot up and configure StructureMap in order to wire together all the
parts of the application.

``` csharp Hello Bootstrapper
public static IContainer BuildContainer() 
{
	ObjectFactory.Initialize(x => 
	{
		x.AddRegistry<UserInterfaceRegistry>();
	});
	
	return ObjectFactory.Container; 
} 
```

The StructureMap configuration is implemented using the nested closure
pattern. After the closure has been executed, the internal dependency
graph of StructureMap is sealed and cannot be changed anymore. I think
this has to do with the ILGeneration aspect of StructureMap. 
 
A `Registry` is the abstraction which is used by StructureMap in order
to modularize the container configuration. If we take a look at the
`UserInterfaceRegistry` from StoryTeller we see a lot of interesting
stuff, but today I would like to focus on the particular part of the
Registry which configures all the conventions. It looks like this:

``` csharp A registry dissected
public class UserInterfaceRegistry : Registry 
{
		public UserInterfaceRegistry() 
		{ 
			... 
			Scan(x => 
			{
				x.TheCallingAssembly(); 
				x.AssemblyContainingType<ITestEngine>(); 
				...
				x.WithDefaultConventions();
				x.ConnectImplementationsToTypesClosing(typeof(IContextualAction<>));
				... 
			});
		} 
		...
} 
```

If you take a look at how most containers work today, you see a lot of
map-this-class-to-that-interface and
map-that-class-with-this-id-under-that-interface stuff when the
container is configured. All of this has to be done mostly by hand and
is very repetitive. Wouldn't it be nice if the IoC container could give
us a helping hand and free us from most of this simple configuration
code? That's exactly what StructureMap tries to do.

The `Scan` block configures StructureMap to automatically scan the
configured assemblies and pass each found type in those assemblies into
a chain of classes implementing the `ITypeScanner` interface. Those
classes are responsible for applying CoC in StructureMap. You can
register a class by adding a

``` csharp Using a custom type scanner
x.With<NameOfConcreteTypeScanner>();
```

to the scan block. The StructureMap assembly contains several
`ITypeScanner` implementations out of the box. One of them is the
`DefaultConventionsScanner` which is configured by 

``` csharp Using the default conventions
x.WithDefaultConventions(); 
```

StructureMaps default convention does the following: For each concrete
type it looks for an interface whose name (minus the "I" prefix) matches
the name of the concrete type. If it finds one, it automatically
registers a mapping between those two types.

``` csharp How DefaultConventionScanner is implemented
public class DefaultConventionScanner : TypeRules, ITypeScanner 
{ 
	public virtual Type FindPluginType(Type concreteType) 
	{ 
		string interfaceName = "I" + concreteType.Name; 
		return Array.Find(concreteType.GetInterfaces(), delegate (Type t) 
		{
			return t.Name == interfaceName; 
		}); 
	} 
	
	public void Process(Type type, PluginGraph graph) 
	{ 
		if (base.IsConcrete(type)) 
		{ 
			Type pluginType = this.FindPluginType(type); 
			
			if ((pluginType != null) && Constructor.HasConstructors(type)) 
			{ 
				graph.AddType(pluginType, type); 
			}
		} 
	} 
} 
```

Conventions are really easy to implement, because the StructureMap
assembly provides a lot of the necessary functionality through extension
methods and base classes. Just to give you an example what you can also
do, here is an example from one of my current projects.

``` csharp Registering named implementations
public class RegisterNamedImplementationsOf<TContract> : TypeRules, ITypeScanner 
{ 
	private readonly string ContractName = FindContractName(); 
	
	#region ITypeScanner Members 
	public void Process(Type type, PluginGraph graph) 
	{ 
		if (IsConcrete(type) && type.Implements<TContract>())
		{ 
			string name = FindImplementationName(type); 
			
			if (!string.IsNullOrEmpty(name) && Constructor.HasConstructors(type))
			{
				graph.AddType(typeof (TContract), type, name); 
			} 
		} 
	} 
	#endregion 
	
	private string FindImplementationName(Type concreteType) 
	{ 
		if (!concreteType.Name.Contains(ContractName)) 
		{ 
			return null; 
		} 
		return concreteType.Name.Replace(ContractName, string.Empty); 
	}
	
	private static string FindContractName() 
	{ 
		return typeof(TContract).Name.TrimStart('I'); 
	}
}
```

The convention basically does this: If you have an `IReportGenerator`
interface and one or more classes are found which implement the
interface and end with "ReportGenerator", they are automatically
registered with their prefix in the container (for instance "Html" for
`HtmlReportGenerator` or "Text" for `TextReportGenerator`. You can set
this convention up by configuring 

``` csharp Registering our custom convention
x.With<RegisterNamedImplementationsOf<IReportGenerator>();
```

Having configured it that way you're able to access for instance
the "Html" generator by calling 

``` csharp Resolving our example generator
container.GetInstance<IReportGenerator>("Html"); 
``` 

Is there a downside of doing it that way?
----------------------------------------------

You certainly loose a lot of debuggability when assembling your
application based on conventions. For me personally this isn't such a
big deal because I always try to use the debugger only when I have no
other option left and rely a lot on my test suite. What you need in
order to overcome this lack of debuggability is some reporting
functionality as a safety net for the rare situations where the
container doesn't behave as you expect it to. To our luck StructureMap
contains helpers for those situations, for example 

``` csharp Asking the container to print out his configuration
ObjectFactory.WhatDoIHave(); 
```

which gives a detailed report on the currently configured dependency graph or

``` csharp Testing whether the container configuration is valid
ObjectFactory.AssertConfigurationIsValid(); 
``` 

which validates the container configuration. A lot of the CoC stuff may
look like "voodhoo" or "black magic" to some developers at first, but I
think they should be able to get used to it. Conventions can be easily
documented and are in my opinion easier to remember as stuff like
if-you-want-to-register-this-you-need-to-add-it-to-file-XY-at-the-end-of-method-Z
. . .

That's all for now. Next time we'll look at how a kind of "startable
facitility" is implemented in StoryTeller . . .
