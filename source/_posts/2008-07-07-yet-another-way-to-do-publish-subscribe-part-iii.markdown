---
author: admin
date: '2008-07-07 16:42:34'
layout: post
slug: yet-another-way-to-do-publish-subscribe-part-iii
status: publish
title: Yet another way to do publish & subscribe Part III . . .
wordpress_id: '16'
? ''
: - Uncategorized
  - Uncategorized
  - Castle Windsor
  - Castle Windsor
  - Inversion of Control
  - Inversion of Control
  - Publish &amp; subscribe
  - Publish &amp; subscribe
---

Today, I discuss the design of what I actually implemented. Please be
aware that I do not claim that it's the perfect solution to the concept
at hand. It's what I've come up with to implement it, which at least for
my context works very well. With that being said, let's dive into the
design.

The core of the design is formed by a class called **Subscription**.
![PubSub.Subscription](http://www.bjoernrochel.de/wp-content/uploads/2008/07/subscription.jpg)
The name is quite self describing, but let me say some words about its
intended purpose in my publish & subscribe implementation. The
subscription is used as an endpoint for sending messages to a
subscriber, hiding away the thread context (**SynchronizationContext**)
of the related subscriber instance and the weak reference handling to
the related subscriber instance from the caller. It's a kind of mediator
instance so to say. Besides that it provides some information about
which message type the subscription is for.Subscriptions are created by
an implementation of the **ISubscriptionAssembler**interface. As the
name implies the main responsibility of this interface is to create
subscriptions either in an explicit (create a single subscription for a
given **ISubscriber<TMessage\>** instance) or implicit (infer all
subscriptions of a given instance / type) manner . . .

[![image](http://www.bjoernrochel.de/wp-content/uploads/2008/07/isubscriptionassembler.jpg "PubSub.ISubscriptionAssembler")](http://www.bjoernrochel.de/wp-content/uploads/2008/07/isubscriptionassembler.jpg)

The current implementation (**SubscriptionAssembler**) uses a small
wrapper around **SynchronizationContext**called **SyncFactory**to
capture the thread context while building the subscription. All this
factory does is that it registers a new **SynchronizationContext**via
**SyncronizationContext.Current** when no context exists. This is
especially useful when doing unit testing (which by default has no
**SynchronizationContext** set). Besides that the
**SubscriptionAssembler**provides functionality to infer all
subscriptions of a particular type and / or instance via reflection.
This is done on top of the classes **SubscriptionInspector**and
**MessageInterestCache**. The **SubscriptionInspector**realizes the
relflection part, while the **MessageInterestCache**serves as a small
cache for optimizing the performance of the assembler (message interests
are only reflected once). Also included is a bit of functionality which
can be used to pre-infer the message interests of a particular type,
which might get handy when integrating with an
InversionOfControl-container (most IoC-container split registration and
type construction). Once subscriptions have been created, they are
managed by an implementation of the **ISubscriptionManager**interface.
This means:

1.  Tracking all subscriptions for a particular message type (with
    operations for adding / releasing and retrieving subscriptions for a
    particular message type).
2.  Detecting and removing dead references (garbage collected
    instances).

[![image](http://www.bjoernrochel.de/wp-content/uploads/2008/07/isubscriptionmanager.jpg "PubSub.ISubscriptionManager")](http://www.bjoernrochel.de/wp-content/uploads/2008/07/isubscriptionmanager.jpg)

The actual **IMessageBus**implementation called **MessageBus**is
implemented only as a small wrapper around the
**ISubscriptionAssembler**(for creating subscriptions) and the
**ISubscriptionManager**(for adding and removing subscriptions
explicitly). Here you can impression what it actually does: [sourcecode
language='csharp'] public class MessageBus : IMessageBus { private
readonly ISubscriptionManager \_SubscriptionManager; private readonly
ISubscriptionAssembler \_SubscriptionAssembler; public MessageBus(
ISubscriptionManager subscriptionManager, ISubscriptionAssembler
subscriptionAssembler) { Ensure.ArgumentIsNotNull(subscriptionManager,
"subscriptionManager"); Ensure.ArgumentIsNotNull(subscriptionAssembler,
"subscriptionAssembler"); \_SubscriptionManager = subscriptionManager;
\_SubscriptionAssembler = subscriptionAssembler; } public void
AddSubscriber(ISubscriber subscriber) where TMessage : class {
Ensure.ArgumentIsNotNull(subscriber, "subscriber"); Subscription
subscription = \_SubscriptionAssembler.CreateSingle(subscriber);
\_SubscriptionManager.Add(subscription); } public void
ReleaseSubscriber(ISubscriber subscriber) where TMessage : class {
Ensure.ArgumentIsNotNull(subscriber, "subscriber");
\_SubscriptionManager.ReleaseSubscription(subscriber); } public void
SendMessage(TMessage message) where TMessage : class {
Ensure.ArgumentIsNotNull(message, "message"); var subscriptions =
\_SubscriptionManager.GetSubscriptions(message.GetType()); foreach
(Subscription subscription in subscriptions) {
subscription.SendMessage(message); } } } [/sourcecode] The interface to
an InversionOfControl-container is the **IocBridge**. This class is just
a small mediator that can be used in combination with the extension
method the container provides. It provides simple access points which
call an **ISubscriptionAssembler**implementation, when an instance has
been configured, try to infer all subscriptions when a new instance has
been created and that release all subscriptions related to a particular
instance when the instance has been removed from the container.

[![image](http://www.bjoernrochel.de/wp-content/uploads/2008/07/iocbridge.jpg "PubSub.IocBridge")](http://www.bjoernrochel.de/wp-content/uploads/2008/07/iocbridge.jpg)

Regarding the design of the publish & subscribe system that's all there
is to tell :-) . Here is a little overview over all classes.
[](http://www.bjoernrochel.de/wp-content/uploads/2008/07/overview.jpg "PubSub.Overview")

[![PubSub.Overview](http://www.bjoernrochel.de/wp-content/uploads/2008/07/overview.jpg)](http://www.bjoernrochel.de/wp-content/uploads/2008/07/overview.jpg "PubSub.Overview")

In the last post I mentioned that my favourite IoC-container is Castle
Windsor. In order to use the library there still is a little piece
missing. I've integrated it with the WindsorContainer by implementing an
IFacility. [sourcecode language='csharp'] public class PubSubFacility :
AbstractFacility { private IIocBridge \_IocBridge; protected override
void Init() { \_IocBridge = Kernel.Resolve();
Kernel.ComponentModelCreated += OnComponentModelCreated;
Kernel.ComponentCreated += OnComponentCreated; Kernel.ComponentDestroyed
+= OnComponentDestroyed; } private void
OnComponentDestroyed(ComponentModel model, object instance) {
\_IocBridge.UninstallInstance(instance); } private void
OnComponentCreated(ComponentModel model, object instance) {
\_IocBridge.TryInstallInstance(instance); } private void
OnComponentModelCreated(ComponentModel model) {
\_IocBridge.TryTypeInstallation(model.Implementation); } } [/sourcecode]
Together with some xml the whole stuff can easily be wired together.
[sourcecode language='xml'] [/sourcecode] That's it with my take on
(local) publish & subscribe. It may not be perfect but it suits my needs
at the moment. I'm planning to integrate the standard .NET APM in the
**IMessageBus**interface in order allow asynchronous message sending and
the common rendezvous techniques. I'm looking forward to any feedback
for my solution and would like to share the code under some OS license,
if someone is interested in. . .
