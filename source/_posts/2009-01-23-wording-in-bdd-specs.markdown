---
author: BjRo
date: '2009-01-23 17:26:48'
layout: post
slug: wording-in-bdd-specs
status: publish
title: Wording in BDD specs
wordpress_id: '221'
comments: true
footer: true
categories: [Testing, dotnet, xUnitBDDExtensions]
---

Last week I had a little discussion on the german ALT.net mailing list
in which I commented on a code example of a spec that **wording in a BDD
spec is of vital importance to BDD and therefore should be chosen very
carefully**. With this post I would like to clarify a bit what I meant
with that. I'd like to add that I still consider myself to be a learner
in the BDD area. So, if you see things differently, feel free to
comment. Let's start by looking back on my own efforts with testing and
BDD. For about 2 years I wrote (what I consider to be) classical unit
tests. Those tests followed strictly a "<MethodName>_<Scenario>_<Behavior>" naming convention originally
proposed by Roy Osherove. Here's short example of what I wrote that
time. 

``` csharp A typical unit test ala Roy Osherove naming style
[Fact] 
public void RegisterSubscriber_NewSubscriber_SubscriberIsRegistered() 
{ 
	var subscriber = new FakeSubscriber();
	subscriptionManager.RegisterSubscriber(subsriber); 
	var wasRegistered = subscriptionManger.AllSubscriptionsFor().Contains(subscriber);

	Assert.True(wasRegistered); 
} 
```

When changing my tests to a more BDD oriented style last august (if you're interested why please
read [here](http://www.bjoernrochel.de/2008/08/27/first-steps-with-bdd/)), my style of writing tests changed to something that looked like this.

``` csharp Sub optimal wording 
[Concern(typeof(SubscriptionManager))]
public class When_registering_a_subscriber_at_the_subscription_manager : InstanceContextSpecification<SubscriptionManager>
{ 
	ISubscriber subscriber; 
	
	protected override void EstablishContext() 
	{ 
		subscriber = new FakeSubscriber(); 
	}

	protected override SubscriptionManager CreateSut()
	{ 
		return new SubscriptionManager(); 
	} 
	
	protected override void Because() 
	{
		Sut.RegisterSubscriber(subscriber); 
	}
	
	[Observation] 
	public void should_be_contained_in_the_list_of_subscriptions_for_the_subscribed_message()
	{ 
		subscriptionManger.AllSubscriptionsFor().ShouldContain(subscriber);
	} 
} 
```
For me at that particular point BDD meant not much more than a bunch of proven practices in test design and a revised
naming convention. So what might be wrong with the way the spec is written here (event in that context)?

1.  It isn't fully refactoring safe (to be fair, the classic unit test shown above wasn't either). Try to rename the term
    SubscriptionManager (or RegisterSubscriber in the first example). No refactoring tool will help you renaming your existing specs. As a
    consequence I would strongly suggest **not to encode type or member names into a specification**.
2.  It doesn describe behavior. It describes implementation. A spec should describe what a system under test is supposed to do, not how
    it achives it. Do you see the word "list" here?

You could revise the spec like this. 
``` csharp A revised spec
[Concern(typeof(SubscriptionManager))] 
public class When_registering_a_new_subscriber : InstanceContextSpecification<SubscriptionManager>
{
	ISubscriber subscriber; 
	
	protected override void EstablishContext() 
	{
		subscriber = new FakeSubscriber(); 
	} 
	
	protected override SubscriptionManager CreateSut() 
	{ 
		return new SubscriptionManager(); 
	}
	
	protected override void Because() 
	{ 
		Sut.RegisterSubscriber(subscriber);
	} 
	
	[Observation] 
	public void should_enable_the_subscriber_to_recieve_messages_he_is_interested_in()
	{ 
		subscriptionManger .AllSubscriptionsFor() .ShouldContain(subscriber);
	} 
} 
```

Having said this, IS THAT THE REASON why I consider wording be to so important to BDD?
----------------------------------------------------------------------------------------
No, not really. Nearly the same applies to classic unit testing, too. We should take a closer look at
BDD in order to reach the answer. 

Was the example shown above even BDD?
-----------------------------------------
IMHO Second no. The example isn't BDD. It only shows a way how a part of BDD can be implemented, with a framework; be it
xunit.bddextensions, SpecUnit, MSpec or any other tool out there. 

hm, ok what is BDD then?
--------------------------
As I understand it so far, BDD was originally created to codify acceptance criterias of stakeholders into executable code in a way which preseverves most/all of the vocabulary the
stakeholder uses. By that a shared language can be established between stakeholders. (Greg Young wrote a nice post about the [subtle difference between BDDs shared language and DDDs ubiquitous
language](http://codebetter.com/blogs/gregyoung/archive/2007/10/16/bdd-and-the-shared-language.aspx), so I won't repeat that here). This shared language is ment to enhance
the way different parties/stakeholders interact with each other, a way to enhance communication. And what is the primary utility used in the interactions between stakeholders in BDD? ==> The executable
specifications.  

Coming back to why wording is so important to BDD 
---------------------------------------------------
What is especially interesting in BDD is, that as there're different stakeholders, [there're also different kind of audiences, with
possibly different kind of vocabulary](http://codebetter.com/blogs/aaron.jensen/archive/2008/10/19/bdd-consider-your-audience.aspx).Â
So because BDD specs are targeted to be an acceptance criteria, they need to be written in the vocabulary of the people who will review them.
This is a huge influence besides all the more technical reasons I touched earlier which of course are relevant, too. Does this make sense
to you?
