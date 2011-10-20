---
author: BjRo
date: '2008-08-29 11:02:08'
layout: post
slug: poor-mans-dependency-injection
status: publish
title: Poor mans dependency injection
wordpress_id: '104'
comments: true
footer: true
categories: [dotnet, Testing]
---
While watching the first of JP Boodhoos screencast series I discovered that a concept that I used in order to introduce testing to developers
who work mostly in legacy code (I'm using Michael Feathers terminology here) is in fact a well known pattern. Let me give you an example.
You've got a class that you want test, but this class somehow depends on an untestable resource like for instance a webservice. You don't have
some kind of dependency inversion to you're hand and have to solve this problem on your own. 
A short example: 

``` csharp An example
public class BillingService 
{ 
	public BillingResult DoBilling(BillingData data) 
	{ 
		Bill theBill = MakeBill(data); 

		using(BillingClient wc = new BillingClient()) 
		{ 
			wc.DoBilling(theBill); 
		} 
	}
} 
```

What I mostly recommend in such a situation is

1.  Extract or isolate the ugly (Quote from Jeremy Miller) which is the webservice call here.
2.  Introduce an interface that shields the class from the webservice call.
3.  Make the whole class rely on the abstraction.
4.  Use two constructors. I mostly reffered to them as the opened and the closed constructor.

``` csharp The refactored BillingService
public class BillingService 
{
	private IBillingSystem _BillingSystem; 

	public BillingService(IBillingSystem billingSystem) 
	{ 
		_BillingSystem = billingSystem; 
	} 
	
	public BillingSystem() : this(new BillingSystem()) 
	{ } 

	public BillingResult DoBilling(BillingData data) 
	{ 
		Bill theBill = MakeBill(data);
		_BillingSystem.DoBilling(); 
	} 
} 

public interface IBillingSystem 
{ 
	void DoBilling(Bill theBill); 
} 

public class BillingSystem : IBillingSystem 
{
	public void DoBilling(Bill theBill) 
	{ 
		using(BillingClient wc = new BillingClient()) 
		{ 
			wc.DoBilling(theBill); 
		} 
	} 
} 
```
With that you can easily replace the untestable code with some kind of testdouble like a stub or a mock. 

``` csharp The ugly dependencies in a test replaced
public class BillingServiceTest 
{ 
	[Fact] 
	public void DoBilling_ValidBill_BillIsCorrectlySendToBillingSystem() 
	{
		BillingSystemStub billingSystem = new BillingSystemStub(); //Replace dependency with a stub
		BillingService billingService = new BillingService(billingSystem);
		BillingData billingData = MakeValidBillingData();
		billingService.DoBilling(billingData); //Do some assertions
		Assert.NotNull(billingSystem.RecievedBill); 
	} 
} 
```
Today I learned that this is also called `POOR MANS DEPENDENCY INJECTION`. 

P.S.:
Mabe the example is not the best one but I didn't want to go into
something like Foo and Bar again. Besides that it's only a simplified
example. Consider that before throwing eggs and tomatos at me :-).

P.S.2: An alternative to this approach which doesn't require a new interface is "Extract & Override".
