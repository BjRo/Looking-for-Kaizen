---
author: BjRo
date: '2008-07-02 18:21:03'
layout: post
slug: yet-another-way-to-do-publish-subscribe-part-ii
status: publish
title: Yet another way to do publish & subscribe Part II . . .
wordpress_id: '9'
comments: true
footer: true
categories: [dotnet, sw-design]
---

As promised on the last post, this time I talk more about what I
actually implemented. Let's start with the basic API. The whole API is
very simple and message centered. In order to be able to recieve
messages you have to implement the `ISubscriber<TMessage>` interface.

``` csharp The ISubscriber<TMessage> interface 
public interface ISubscriber<TMessage> 
{ 
	void Handle(TMessage message); 
}
``` 
The generic parameter `TMessage` specifies the type of message the subscriber is interested
in. The message should simply be implemented by a POCO. Examples could
be:

-   `ISubscriber<ActivePatientChanged>`
-   `ISubscriber<ApplicationTitleChanged>`
-   `ISubscriber<CsvExportFinished>`

A consumer class wants to publish messages or to register itsself for a
particular message needs to have a reference to an `IMessageBus` implementation. 
This interface serves as a consumer side facade to the pubsub system. 

``` csharp The IMessageBus interface
public interface IMessageBus 
{ 
	void AddSubscriber(ISubscriber subscriber); 
	void ReleaseSubscriber(ISubscriber subscriber); 
	void SendMessage(TMessage message); 
} 
```
From a consumer perspective that's all your need to known when dealing with publish & subscribe. 
Together with type inference it's event nicer to use :-). 

``` csharp Putting it together
public class DemoMessage { } 

public class MyListener : ISubscriber 
{
	public void Subscribe(IMessageBus bus) 
	{ 
		bus.AddSubscriber(this); 
	}

	public void Handle(DemoMessage message)
	{
	}
} 

public class MyPublisher 
{
	IMessageBus _Bus; 
	
	public MyPublisher(IMessageBus bus) 
	{ 
		_Bus = bus; 
	} 
	
	public void Demo()
	{ 
		_Bus.SendMessage(new DemoMessage());
	}
}
```

Some other characteristics also worth mentioning:

-   The current implementation captures the thread context when a
    subscriber is registered. All callbacks will be handled on the same
    thread on which they were registered.
-   Only a weak reference is held to the subscriber. This guarantees
    that a subscriber can be garbage collected although not properly
    unregistered from the publish & subscribe system. The implementation
    detects dead references and removes them automatically.

With that beeing said I would like too conclude the series about publish
& subscribe with a post about the actual implementation which will
follow up . . .
