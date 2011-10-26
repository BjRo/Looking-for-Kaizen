---
author: BjRo
date: '2009-07-08 23:19:01'
layout: post
slug: thats-why-i-like-open-source
status: publish
title: That’s why I like Open Source . . .
wordpress_id: '384'
comments: true
footer: true
categories: [dotnet, Testing, xUnitBDDExtensions]
---

Today I received a really nice feature for xUnit.BDDExtensions from a
former colleague and friend of mine. It came to me completely with a
spec demonstrating and documenting its usage. Completely awesome. I wish
day to day software development would always be like that.

The feature deals with chained properties on interfaces. Consider the
following example: A presenter working against a composed passive view.

``` csharp A complex MVP view interface
public interface IComplexView 
{ 
	ISubView Header {get;set;} 
} 

public interface ISubView 
{ 
	string Description {get;set;} 
}
public class Presenter 
{ 
	private IComplexView _view;
	
	public Presenter(IComplexView view)
	{
		_view = view; 
	}
	
	public void Initialize() 
	{ 
		_view.Header.Description = "Some caption . . ." 
	} 
}
````

A spec documenting the behavior of the presenter can now look
like this if you're using xUnit.BDDExtensions. 

``` csharp Using the HasProperties() extension method
[Concern(typeof(Presenter))] 
public class When_the_presenter_is_initialized : InstanceContextSpecification<Presenter>
{
	protected override EstablishContext() 
	{ 
		The<IComplexView>().HasProperties(); 
	}
	
	protected override void Because() 
	{ 
		Sut.Initialize(); 
	} 
	
	[Observation]
	public void It_should_set_the_headers_caption() 
	{
		The<IComplexView>().Header.Description.ShouldBeEqualTo("Some caption ... ");
	}
}
```

A really large portion of the necessary glue code has been
removed for that scenario. Only the `HasProperties()` extension method
remains.

Great work, Sergey. I really like the implementation of that feature ...
