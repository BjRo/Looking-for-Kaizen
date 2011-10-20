---
author: BjRo
date: '2008-08-27 13:35:06'
layout: post
slug: first-steps-with-bdd
status: publish
title: First steps with BDD
wordpress_id: '79'
comments: true
footer: true
categories: [dotnet, Testing]
---

One of the positive things of being ill and staying at home is having
time to look into stuff I always wanted to look into but never actually
had the time to. A good example for this is Behavior Driven Development
or in short BDD. BDD is described by its creator Dan North as an
enhancement to classic TDD with an emphasis on behavior specifications.
It tries to provide business value by using classes and methods written
as human readable sentences which can be reflected in order to generate
a behavior specification document for the classes under test. The
document can fulfill multiple purposes. It could be used as
documentation for the tested system and even more important as an
enabler for the ubiquitous language of the project (in terms of Evans
DDD). 

Before looking at something more concrete about BDD, first a brief
history of my personal experience with testing throughout the last 3
years. I think this helps me to clarify, why I liked BDD from the moment
I started reading about it. My first unit tests looked very much like a
lot of tests I've seen from a lot of people starting with unit tests
since. (The examples are using the NUnit syntax but you can project this
to any unit testing framework you want.) 

Every fresh start is hard.
--------------------------------
``` csharp Unstructured tests
[TestFixture] 
public class FactoryTest 
{
	private Factory _Factory; 
	
	[SetUp] 
	public void SetUp() 
	{ 
		_Factory = new Factory(); 
	}
	
	[Test] 
	public void Test1() 
	{ 
		SomeProduct product = _Factory.Create("FooProduct"); 
		
		Assert.IsNotNull(product);
		Assert.AreEqual(product.Name, "FooProduct");
		Assert.AreEqual(product.Vendor, "Foo"); 
	}
	
	[Test]
	[ExpectedException(typeof(ArgumentNullException))] 
	public void Test2() 
	{
		_Factory.Create(null); 
	} 
}
```
For every class I wanted to test I wrote a corresponding test class, 
which had the suffix "Test" and contained all tests for that class under test. 
I discovered later that this is a testing strategy known as `TEST-CASE-CLASS-PER-CLASS`
while reading "XUnit Test Patterns" by Gerard Meszaros. At that time it felt pretty confident with what I did. I mean, I wrote tested code, which was
to a particular degree bug free. Yeah right, but let's have a look at the downside of what I was doing:

-   When such a test failed I didn't have a clue what the test was actually verifying. I had to debug the testcode.
-   When a test like `Test1` failed I didn't know what assertion was broken. I had to debug the testcode.
-   It didn't scale well. I became quite messy and unclear as the number of tests increased.
-   I always hat a hard time coming back to the test after having spend days in a different topic.

Incorporating a standard naming scheme for tests
-------------------------------------------------
As one result of the observed problems I incorporated a standard naming scheme (inspired by a post of Roy Osherove) 
to my tests which followed the following scheme: `MethodName_Scenario_Behavior`.
Applied to the sample code it would look like this: 

```csharp Applying a name scheme
[TestFixture]
public class FactoryTest 
{ 
	private Factory _Factory; 
	
	[SetUp] 
	public void SetUp() 
	{ 
		_Factory = new Factory(); 
	}
	
	[Test] 
	public void Create_ValidCreationData_CreatesAValidProduct()
	{
		SomeProduct product = _Factory.Create("FooProduct"); 
		Assert.IsNotNull(product);
		Assert.AreEqual(product.Name, "FooProduct");
		Assert.AreEqual(product.Vendor, "Foo"); 
	} 
	
	[Test]
	[ExpectedException(typeof(ArgumentNullException))] 
	public void Create_NullForArgument_ThrowsArgumentNullException() 
	{
		_Factory.Create(null); 
	}
}
```
The naming scheme helped me a lot for maintaining my tests. When a test failed I knew instantly a)
which class was tested, b) what the test scenario was and c) what the expected behavior was, that was broken. However, the problem with the
multiple assertions still existed. You can fix this issue by providing error messages with every assertion. I must admit that I never really
liked that approach. I would rather go down the `SINGLE-ASSERTION-PER-TEST-METHOD` way. 

This way you have the behavior of the class under test completely discoverable by a unit test framework
which is something I appreciate. (Maybe I'm alone with this. Several members of my team disagree with this.) 

Single Assertion per Test
--------------------------------
After refactoring the test it would look like this: 

``` csharp Adding single assertions per test
[TestFixture] 
public class FactoryTest 
{ 
	private Factory _Factory; 

	[SetUp] 
	public void SetUp() 
	{ 
		_Factory = new Factory(); 
	}
	
	[Test] 
	public void Create_ValidCreationData_CreatedProductHasName() 
	{ 
		SomeProduct product = _Factory.Create("FooProduct"); 
		
		Assert.AreEqual(product.Name, "FooProduct"); 
	} 
	
	[Test] 
	public void Create_ValidCreationData_CreatesProductHasNameOfVendor() 
	{
		SomeProduct product = _Factory.Create("FooProduct");
		Assert.AreEqual(product.Vendor, "Foo"); 
	} 

	[Test]
	[ExpectedException(typeof(ArgumentNullException))] 
	public void Create_NullForArgument_ThrowsArgumentNullException() 
	{
		_Factory.Create(null); 
	}
} 
```
One downside of this approach is the sudden code duplication you now have in the code. It isn't that
big in the example but it can be in reality. You should treat test code as you're treating production code. Don't repeat yourself! I usually
dealt with that situation by switching the test strategy. 

Switching to TEST-CLASS-PER-FIXTURE
------------------------------------
`TEST-CLASS-PER-FIXTURE` is again a test strategy described by Gerald Meszaros in this book "XUnit Test Patterns". 
The basic idea is that you split your test classes into several test classes based on the common initialization / execution logic the methods share.
Applied to the sample code this would result in this: 

``` csharp Applying Test case class per fixture
[TestFixture] 
public class FactoryTest_ArgumentTests
{ 
	private Factory _Factory; 
	[SetUp] 
	public void SetUp() 
	{ 
		_Factory = new Factory(); 
	} 
	
	[Test]
	[ExpectedException(typeof(ArgumentNullException))] 
	public void Create_NullForArgument_ThrowsArgumentNullException() 
	{
		_Factory.Create(null); 
	} 
}

[TestFixture] 
public class FactoryTest_CreatingAValidProduct 
{ 
	private Factory _Factory; 
	private SomeProduct _Product; 
	
	[SetUp] 
	public void SetUp() 
	{ 
		_Factory = new Factory(); 
		_Product = _Factory.Create("FooProduct"); 
	}
	
	[Test] 
	public void Create_ValidCreationData_CreatedProductHasName() 
	{
		Assert.AreEqual(_Product.Name, "FooProduct"); 
	} 

	[Test] 
	public void Create_ValidCreationData_CreatesProductHasNameOfVendor() 
	{
		Assert.AreEqual(_Product.Vendor, "Foo"); 
	}
} 
```
I've worked with that approach for 2 years now. It suited my needs very well.
However the tests are often not as expressive as I like them to be in terms of the naming. 
I'll guess there's a better naming scheme when using something like the `TEST-CASE-CLASS-PER-FIXTURE` testing strategy
and that's where the circle closes for me. 

Coming back to BDD 
--------------------
While working through the preparation material for JP Boodhoos Nothing but .NET bootcamp I 
made first contact with his style of applying BDD. I must admit that I'm pretty amazed, 
because I've seen a lot of things of value for me. Sometimes sourcecode says more than 
a thousand words, so this is what the sample would look like if his BDD conventions have been
applied to it: 

``` csharp The same tests context specification style
[Concern(typeof (Factory))] 
public class When_creating_a_valid_product : ContextSpecification 
{ 
	private Factory _Factory; 
	private Product _CreatedProduct; 

	protected override void establish_context() 
	{
		_Factory = new Factory(); 
	} 
	
	protected override void because() 
	{
		_CreatedProduct = _Factory.Create("Foo"); 
	} 
	
	[Observation] 
	public void the_product_should_contain_the_correct_product_name() 
	{
		_CreatedProduct.Name.should_be_equal_to("FooProduct"); 
	}

	[Observation] 
	public void the_product_should_contain_the_correct_vendor_name() 
	{
		_CreatedProduct.Vendor.should_be_equal_to("Foo"); 
	} 
}

[Concern(typeof(Factory))] 
public class When_passing_null_for_product_name : ContextSpecification 
{
	private Factory _Factory; 
	private Action _Call; 

	protected override void establish_context()
	{ 
		_Factory = new Factory(); 
	} 
	
	protected override void because() 
	{ 
		_Call = The.Action(() => _Factory.Create(null));
	}

	[Observation] 
	public void should_throw_an_ArgumentNullException() 
	{
		_Call.should_throw_an(); 
	} 
} 
``` 
Here is the base class that provides the hooks for the unit test framework (in this case MbUnit). 

``` csharp The ContextSpecification base class
using MbUnit.Framework; 
using Context = MbUnit.Framework.TestFixtureAttribute; 
namespace NothinButDotNetPrep.SpecHelpers 
{ 
	[Context] 
	public abstract class ContextSpecification 
	{
		[SetUp] 
		public void setup()
		{
			establish_context(); 
			because(); 
		} 
		
		[TearDown] 
		public void teardown() 
		{
			after_each_specification(); 
		} 
		
		protected abstract void because();
		protected abstract void establish_context(); 
		protected virtual void after_each_specification() { } 
	}
} 
```
I like his way to implement the AAA (arrange, act and assert) pattern with the template
method pattern and C# 3.0 extension method for the actual assertions very much. It feels like a natural progression to what I've been doing
previously with a lot better readability. Another interesting thing is that he uses a tool called `bddunit` to generate a behavior
documentation from the tests. A generated documentation would look like this:

Behavior of Factory

-   When creating a valid product
    -   the product should contain the correct vendor name.
    -   the product should contain the correct product name.

-   When passing null for product name
    -   should throw an ArgumentNullException

I'll definitely have to dig more into this. If you're interested in
learning more about BDD here are some links I've read this morning.

-   Dan North: [Introducing BDD](http://dannorth.net/introducing-bdd).
-   AgileJoe: [Attempting to demyistify BDD](http://www.lostechies.com/blogs/joe_ocampo/archive/2007/08/07/attempting-to-demystify-behavior-driven-development.aspx).
-   JP: Bodhoo: [Getting started with BDD style Context / Specification base naming](http://codebetter.com/blogs/jean-paul_boodhoo/archive/2007/11/29/getting-started-with-bdd-style-context-specification-base-na.aspx).
-   Jimmy Bogard: [Converting tests into specs is a bad idea](http://grabbagoft.blogspot.com/2008/01/converting-tests-to-specs-is-bad-idea.html).
-   David Laribee: [Approaching BDD.](http://codebetter.com/blogs/david_laribee/archive/2007/12/17/approaching-bdd.aspx)

