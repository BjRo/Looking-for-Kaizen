---
author: BjRo
date: '2008-08-28 11:53:06'
layout: post
slug: bdd-with-xunit
status: publish
title: BDD with Xunit
wordpress_id: '100'
comments: true
footer: true
categories: [dotnet, Testing, xUnitBDDExtensions]
---
My current tool of interest is XUnit. For those of you who haven't heard
of it it's a relatively new unit testing framework from Brad Wilson and
the original author of NUnit 2.0, James Newkirk. You can find it [here](http://www.codeplex.com/xunit). Some of the things I really like
about it:

-   It has a set of .NET 3.0 Extension methods, which can be used
    instead of classic assertions (f.e.:  `"Foo".ShouldNotBeNull()` )
-   It runs every every test on a separated instance.
-   It uses the constructor of the test class and the `Dispose`-pattern
    for fixture initialization and release of resources after a test.
-   It's relatively easy to extend XUnit.

Because of curiosity and my current affection with BDD I decided to port
the BDDExtension stuff from JP Boodhoo to XUnit. 
So here we go:

Marking specifications with concerns 
--------------------------------------
All specifications for a particular type are marked with the `ConcernAttribute`.
This is only a marker attribute by which a tool like `bddunit`is able to correlate
specifications and their related type. 

``` csharp The ConcernAttribute
[AttributeUsage(AttributeTargets.Class, AllowMultiple = false, Inherited = false)] 
public class ConcernAttribute : TraitAttribute 
{ 
	private readonly Type _Type; 
	public ConcernAttribute(Type type) : base("Concern", type.FullName) 
	{ 
		_Type = type; 
	} 
	
	public Type Type { get { return _Type; } } 
}
```

The `ConcernAttibute` extends the `TraitAttribute` which is described in the documentation as 

{%blockquote From the xunit documentation %}
an Attribute used to decorate a test method with arbitrary name/value pairs.
{%endblockquote %}

I changed the `AttributeTarget`from method to class in order to suit my needs. 

Changing the way the test is executed
-----------------------------------------
JP's original code relied on the `SetUp` and `Teaddown` handlers of NUnit / MBUnit which are execute before and 
after each test method in the same class. Since XUnit doesn't have that feature any more we'll have to
extend it a bit. 

The main extension point for how a test is executed is the `FactAttibute`used to mark a method as a test. 
You can extend it and return a different `ITestCommand` which is then used to execute the test.
``` csharp The ObservationAttribute
public class ObservationAttribute : FactAttribute 
{ 
	protected override IEnumerable<ITestCommand> EnumerateTestCommands(MethodInfo method)
	{
		var testCommand = base.EnumerateTestCommands(method).First(); 
		yield return new SpecificationTestCommand(testCommand, method); 
	} 
} 
```
Do you wonder why the method returns an `IEnumerable<ITestCommand>`? This is
done in order to support something like row tests in MBUnit. The XUnit framework basically enables you to run a test several times. 
For me this isn't interesting so I just grabbed the first `ITestCommand` from it and wrapped it with my own implementation, 
which looks like this:

``` csharp The SpecificationCommand
public class SpecificationTestCommand : BeforeAfterCommand 
{ 
	public SpecificationTestCommand(ITestCommand innerCommand, MethodInfo testMethod) : base(innerCommand, testMethod) 
	{
	}

	public override MethodResult Execute(object testClass) 
	{ 
		var specification = testClass as IContextSpecification; 
		
		if (specification == null) 
		{ 
			throw new InvalidOperationException("Instance does not implement IContextSpecification"); 
		} 
		
		try
		{ 
			specification.EstablishContext(); 
			specification.Because(); 
			return base.Execute(testClass); 
		} 
		catch(AssertException) 
		{ 
			throw; 
		} 
		catch(Exception exception) 
		{
			ExceptionUtility.RethrowWithNoStackTraceLoss(exception.InnerException);
		}
		
		return null; 
	}
} 
```
The code requires the test class to implement the `IContextSpecification` interface in 
order to invoke the `EstablishContext()` and `Because()` methods for doing AAA based tests.
(Do you miss `AfterEachSpec`? One moment please :-)) 

For every interface there is a base class which is in my case the `ContextSpecification` class.

``` csharp A specification base class
public abstract class ContextSpecification : IContextSpecification, IDisposable 
{ 
	protected abstract void Because(); 
	protected abstract void EstablishContext();
	
	protected virtual void AfterEachSpec() 
	{
	} 
	
	#region IContextSpecification Members 
	
	void IContextSpecification.Because() 
	{
		Because(); 
	} 
	
	void IContextSpecification.EstablishContext() 
	{
		EstablishContext(); 
	} 

	#endregion 

	#region IDisposable Members public
	
	void IDisposable.Dispose() 
	{ 
		AfterEachSpec(); 
	} 
	
	#endregion 
}
``` 
Notice some things. `AfterEachSpec()` is called from `Dispose()`, That's why I
didn't need to include it into the `IContextSpecification` interface.
That interface is implemented explicitly in order to allow the hooks to
have different modifiers (protected). 

Putting it all together
-------------
There's always an interesting moment when you first run your little experiment. Here we
go: 
``` csharp The first spec
[Concern(typeof(Factory))] 
public class When_creating_product_with_a_valid_name : ContextSpecification 
{
	private Factory _Factory; 
	private Product _CreatedProduct; 
	
	protected override void EstablishContext() 
	{ 
		_Factory = new Factory(); 
	} 
	
	protected override void Because() 
	{ 
		_CreatedProduct = _Factory.Create("Foo"); 
	} 
	
	[Observation] 
	public void The_product_should_contain_the_correct_name() 
	{
		_CreatedProduct.Name.ShouldEqual("Foo"); 
	} 
	
	[Observation] 
	public void The_product_should_contain_the_correct_vendor_name() 
	{
		_CreatedProduct.VendorName.ShouldEqual("FooVendor"); 
	} 
} 
```
And the result from TestDriven.NET is: 
------ Test started: 
Assembly: Xunit.BddExtensions.Samples.dll 
------ 2 passed, 0 failed, 0 skipped, took 0,92 seconds. 

Conclusions
-----------------
It's in fact very easy to extend XUnit. I like the tool even more after doing this little research. 
The shown code runs smoothly with TestDriven.NET. However the Resharper - TestRunner seems to have problems with it (TestExplorer stays blank).
I'll play with that approach in the next few weeks and will blog about my experience with both XUnit and BDD. So if you're interested in more
stay tuned . . . 

P.s.: If you're interested in the code, just drop me a line . . .
