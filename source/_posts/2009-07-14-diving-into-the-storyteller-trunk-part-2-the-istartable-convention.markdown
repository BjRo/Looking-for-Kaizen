---
author: BjRo
date: '2009-07-14 09:49:46'
layout: post
slug: diving-into-the-storyteller-trunk-part-2-the-istartable-convention
status: publish
title: 'Diving into the StoryTeller trunk, Part 2: The IStartable convention'
wordpress_id: '411'
comments: true
footer: true
categories: [dotnet, StoryTeller, StructureMap]
---
In the last post I talked a bit about how "Convention over
Configuration" is applied to container registration in the StoryTeller
trunk. Another neat convention which can be found in the bootstrapping
process of StoryTeller is a convention around startable instances .

Each instance in the StoryTeller assemblies whose contract applies to
StructureMaps default convention and also contains the `IStartable`
interface is automatically resolved and started during bootstrapping.

For example: If you've defined an `IModuleLoaderService` contract 

``` csharp Marking a service as startable
public interface IStartable 
{ 
	void Start();
} 

public interface IModuleLoaderService : IStartable { } 
```

and an implementation for it

``` csharp Implementing Start()
public class ModuleLoaderService : IModuleLoaderService 
{
	public void Start() 
	{ ... } 
} 
````

the convention will automatically resolve that implementation and call
the `Start()` method on it. All of this is done by this little piece of
code:

``` csharp The container model exposes everything we need
ObjectFactory.Model.PluginType
	.Where(p => p.IsStartable()) 
	.Select(p => p.ToStartable())
	.Each(x => x.Start());
```

The code itself is not that hard to understand. A bit LINQ combined with
two extension methods. The first one `IsStartable()` finds all known
known contracts (the plugin type) in the dependency graph who are
assignable to the `IStartable` type, while the second one (`ToStartable()`)
simply resolves any found contract type with the help of the container.

Short, simple and easy to remember ==> Love it
