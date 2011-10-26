---
author: BjRo
date: '2009-07-07 18:48:04'
layout: post
slug: how-to-shoot-yourself-in-the-foot-with-ilmerge
status: publish
title: How to shoot yourself in the foot with ILMerge
wordpress_id: '370'
comments: true
footer: true
categories: [dotnet, Testing, xUnitBDDExtensions]
---

xUnit.BDDExtensions and is now completely merged into a single assembly.
However, getting to that state wasn't as straight forward as I
originally expected.

The initial problem
-------------------------
xUnit.BDDExtensions internally depends on StructureMap,
StructureMap.AutoMocking and Rhino.Mocks. However, I don't like the need
to carry around 3 extra assemblies with me, especially if I don't use
them directly in the xUnit.BDDExtensions API. So I decided to give
[ILMerge](http://research.microsoft.com/en-us/people/mbarnett/ilmerge.aspx)
a try and started with this: \

``` bash
ILMerge.exe /t:library /out:'Deploy/xUnit.BDDExtensions.dll' 
	'xUnit.BDDExtensions.dll'
	'StructureMap.dll' 
	'StructureMap.AutoMocking.dll' 
	'Rhino.Mocks.dll'
```

Initial merging went fine, but when I tried to actually use the merged
assembly in a solution also containing a StructureMap binary, I received
a lot of build errors indicating duplicate types. The solution simply
didn't compile any more. Crap !

What went wrong
--------------------
The way I merged the assemblies, all public types of the dependent
assemblies stayed public (although they're only internally used). The
merged assembly exposed all public APIs of the merged-in assemblies.
When using the assembly in conjunction with one of the original
assemblies (for instance StructureMap) the compiler basically didn't
know which type my code was actually referring to. Hence the error.

Besides the observed effect those APIs can clearly be confusing to a
developer with no knowledge that the assembly at hand is actually a
merged one. So imho definitely a situation which needed to be fixed. 

How to fix it
---------------
What needed to be done is to internalize the all public types of the
merged-in assemblies. The related switch for this in ILMerge is `/internalize`.

``` bash
ILMerge.exe /t:library /internalize
		/out:'Deploy/xUnit.BDDExtensions.dll' 
		'xUnit.BDDExtensions.dll'
		'StructureMap.dll' 
		'StructureMap.AutoMocking.dll' 
		'Rhino.Mocks.dll'
````
The solution using both xUnit.BDDExtensions and StructureMap now
compiled without errors. Duplicate type issue solved. Everything fine
now? Nope, obviously internalization created some other problems: Specs
driven by xUnit.BDDExtensions showed that neither the auto-mocking
feature nor the mock support worked anymore. Nearly every test failed
due to an internal exception.

How to fix it (Take 2) 
--------------------------
The problem with the internalization of all public types is that
sometimes the merged APIs somehow depend on several types being public.
If you take that away, you effectively break their functionality. In my
case my problems where created by Castle.DynamicProxy2 (which is used by
Rhino.Mocks internally) and StructureMap. Both tools are doing dynamic
type generation internally and the generated types wanted to implement
some interfaces which were formally public but now weren't accessible
any more. To my luck ILMerge provides a workaround for situations like
that: You can exclude types from being internalized. Here's what I did
in order to make it work: 

``` bash
ILMerge.exe /t:library
	/internalize:'Build/ILMergeIncludes.txt'
	/out:'Deploy/xUnit.BDDExtensions.dll'
	'xUnit.BDDExtensions.dll'
	'StructureMap.dll'
	'StructureMap.AutoMocking.dll' 
	'Rhino.Mocks.dll'
```
Notice the modified `/internalize` switch. A file now specifies the
types to exclude from the internalization. ILMerge expects the file to
contain a regular expression per line. Every line is evaluated against
each type name and automatically excluded from the internalization
process in case the regular expression matches. My exclude file looks
like this:

``` csharp
StructureMap.InstanceBuilder
StructureMap.Pipeline.\* 
Rhino.Mocks.Interfaces.IMockedObject
Castle.Core.Interceptor.IProxyTargetAccessor
Castle.DynamicProxy.AbstractInvocation
Castle.DynamicProxy.Generators.AttributesToAvoidReplicating 
```
Lessons learned 
-----------------
Merging for deployment isn't that hard, but you have to be careful
that everything works as expected after you've created the merged
assembly. A successful ILMerge call doesn't necessarily mean that
everything's fine and works as expected. On the other hand the ILMerge
documentation is very good and provided me with a simple solution to the
problem. I've shot myself in the foot, but it's bandaged and I can walk
again, so to say. If you're interested in doing something similar (not
the shooting part) I highly suggest that you should give ILMerge a try .
. .

Sidenotes
-----------
Is it possible that ILMerge fails to merge WPF based assemblies? I'm
currently experiencing strange effects when trying to merge them. Anyone?
