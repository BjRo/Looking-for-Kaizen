---
author: BjRo
date: '2008-07-28 10:18:33'
layout: post
slug: using-extensionmethods-in-net-20-projects
status: publish
title: Using Extensionmethods in .NET 2.0 projects . . .
wordpress_id: '18'
comments: true
footer: true
categories: [dotnet, trickery]
---

While reading *C# in depth* by Jon Skeet I discovered a little gem. It is possible to use extension methods in .NET 2.0 projects when you're
using VS2008 and its multitargeting abillities. Extension methods are essentially only static methods in utillity classes with some
constraints around them (the utility class has to be static too for instance.) The compiler and intellisense enable you to treat the method
as if it were an instance method, but when you look inside the compiled IL you'll see that that's just a nice shortcut which is transformed to
an actual call into the static method on the utility class. 
<!--more-->

So from a technical perspective there shouldn't be much that keeps us from using extension methods in .NET 2.0 targeted projects. A first try:

``` csharp Our testcase for extension methods in C# 2.0
[TestClass] 
public class UnitTest1 
{
	[TestMethod] 
	public void CanInvokeExtensionMethod() 
	{ 
		MyClass myClass = new MyClass(); 

		//Invoking the extension method
		myClass.Do(); 
	} 
} 

internal class MyClass { } 

//Here's our class containing the extension method
internal static class MyClassUtils 
{ 
	public static void Do(this MyClass myClass) { } 
} 
```

This doesn't compile: The error message send by the compiler is: 

{% blockquote %}
Cannot define a new extension method because the compiler required type 'System.Runtime.CompilerServices.ExtensionAttribute' cannot be found. 
Are you missing a reference to System.Core.dll?
{% endblockquote %}

Now what comes to rescue? The current compiler only searches for the full typename and
doesn't specify an assembly. If you create an attribute with the correct name and the correct namespace inside YOUR assembly the compiler warning
disappears. 

``` csharp Faking the ExtensionAttribute 

namespace System.Runtime.CompilerServices 
{ 
	public class ExtensionAttribute : Attribute { } 
} 
``` 

That beeing done the build succeeds and I've got a smile on my face .....
