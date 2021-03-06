---
author: BjRo
date: '2009-01-26 16:33:59'
layout: post
slug: automocking-in-xunitbddextensions
status: publish
title: AutoMocking in xUnit.BDDExtensions
wordpress_id: '248'
comments: true
footer: true
categories: [Testing, dotnet, xUnitBDDExtensions]
---

``` csharp Automocking in xUnit.BDDExtensions
public class when_an_automatically_resolved_instance_with_a_single_dependency_is_used_in_a_fixture : InstanceContextSpecification<AutomaticallyCreatedInstance>
{ 
	private object actualResult; 
	private IDependency dependency; 
	private object expectedResult; 
	
	protected override void EstablishContext() 
	{ 
		expectedResult = new object();
		dependency = AutoDependency<IDependency>(); 
		dependency.WhenToldTo(x => x.Invoke()).Return(expectedResult); 
	} 
	
	protected override void Because() 
	{ 
		actualResult = Sut.Invoke(); 
	} 
	
	[Observation] 
	public void should_be_able_to_verify_calls_made_to_the_dependency() 
	{
		dependency.WasToldTo(x => x.Invoke()); 
	} 
	
	[Observation] 
	public void should_execute_the_configured_behavior_on_the_dependency() 
	{
		actualResult.ShouldBeEqualTo(expectedResult); 
	} 
} 
```

This little feature was added to the trunk today. Yes, no CreateSut() call. You can omit it for most of the simple scenarios. You can still
override it, if you need/have to. It uses the AutoMocking capabilities of StructureMap internally.

I'm going to merge the different involved assemblies to a single assembly soon in order to make deployment a bit easier . . .
