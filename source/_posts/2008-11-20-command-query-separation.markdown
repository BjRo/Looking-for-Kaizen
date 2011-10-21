---
author: BjRo
date: '2008-11-20 03:08:16'
layout: post
slug: command-query-separation
status: publish
title: Command Query Separation
wordpress_id: '194'
categories: [Conferences]
footer: true
comments: true
---

Does this sound familiar to you? From time to time someone delivers you answers to questions that have been on your mind for quite a while. You
didn't find an answer on your own and most of the people you talked with either didn't care or hadn't satisfying answers for you. When you
finally hear the answers you were searching for, you're . . .

1.  stunned how simple the actual solution is,
2.  wondering why you weren't able to solve that on your own,
3.  nevertheless happy and thankful to finally see the missing piece in
    your puzzle.

Today I had the luck to be able to talk with Gregory Young about (Distributed) Domain Driven Design in general and in particular some
about questions regarding bidirectional mapping from domain object to DataTransferObject, and how messaging or eventing integrates with DDD.
This is what I took from that discussion . . . 

**At first there was the problem . . .** 

It's widely accepted and adopted that domain objects should not be used for displaying data in the UI. The UI should not
dictate the shape of your domain object, nor should it require the domain class to implement stuff (for instance `INotifiyPropertyChanged`).
Because of that, you introduce DataTransferObjects for displaying data in the UI. This is beneficial because all of a sudden you're able to
have different views on the same domain object. Nearly the same applies for distributed scenarios. Tech-specific stuff like attributes for
serialization or the need for public getters and setters should not dictate the shape of your domain object. Again the answer is
DataTransferObject, because they protect the domain objects from infrastructure related needs. The situation becomes even more
interesting, when you want your domain model to have a more behavior oriented design, where behavior is best expressed through methods and
with less properties. Why should you do this? First you can protect the validity of your domain object far better with bundling changes that you
can make on it, in methods. With that you get rid of temporary invalid state in which all of the properties are set to correct values and live
in your domain model becomes easier in a lot of places (because you don't have to check for validity everywhere). Second why should the data
be exposed anyway, if not for display or persistence? What about Data-encapsulation, anyone? So if you remove all the getter setter stuff
from domain objects, how do you do the mapping to a DTO without imposing some shape constraints on the domain object. ? And how do you do that
mapping without inventing the next hot reflection & attribute based thing of the day? I know a lot of applications in which domain objects
and DTOs look exactly the same (with the only subtle difference that the domain object lacks some of the attributes or implemented interfaces of
the DTO) because of that problem. What is the benefit of this? For some systems with public APIs consumed by a third party this might make
sense, because it delivers the ability to develop the internal API separated from the public one. For the rest of all applications out
there it introduces reversibility and flexibility at the cost of the overhead for DTOs. This is very often hard to communicate, because the
benefit is not so obvious. 

. . . and then came the solution:
----------------------------------
You'll have to separate write access to your domain from the read access which is exactly known as the Command Query Separation. I made
some sketches while listening to Greg talk, because I had to visualize this for myself. (They look awful, I know but having a picture to
describe something is better compared to having none . . ) Look at the following sketch. It tries to show the data flow trough an application
for a simple read-update-scenario. 
	
[![IMG_1750]({{root_url}}/images/posts/img-1750-thumb.jpg)]({{ root_url }}/images/posts/img-1750.jpg)

The interesting part is that the mapping from domain object to DTO is missing. The query side is fully based on DTOs. When the something is
changed a command is executed which performs the action on the domain model and persists the changes via the repositories. Looks like a
circle, doesn't it? How is the situation when we have a read-update scenario a multi proc application, for instance classic client / server?
I tried to capture that too. Using the separation it doesn't seem too hard to integrate.

[![IMG_1754]({{ root_url }}/images/posts/img-1754-thumb.jpg)]({{ root_url }}/images/posts/img-1754.jpg)

What's new in the picture? MessageHandlers ! They can receive and send messages and serve as communication endpoints. Besides that the
presentation stays pretty much the same. 

Integrating change notifications to the model 
----------------------------------------------------
What is also very easy to integrate into this architecture are change notifications. The following sketch shows
only the command portion of the sketches above. The only thing we need
to do in order to do change notifications is to publish messages /
events into a message bus / event bus when we've changed something on
our domain objects.

[![IMG_1751]({{ root_url }}/images/posts/img-1751.jpg)]({{ root_url }}/images/posts/img-1754.jpg)

With that we can add change logging, tracking, monitoring in a very loosely coupled way (and that are only a few possibilities). 

Final thoughts
---------------
Isn't there a chapter in Eric Evans book called "Refactoring to deeper insight" ? That somehow describes how I currently feel. The
proposed solution is very flexible, supports poco domains which focus on behavior and protects that domain from infrastructure related stuff. I
do not claim it to be the solution, but it certainly is a valid solution to the problem. What I like about it in particular is how nicely it
integrates with my [thoughts about validation logic]({{ root_url }}/2008/11/08/some-thoughts-about-validation-logic/) (domain validation is always in valid state, validation is done at the
domain edge). 

Greg, if you're reading this, thanks a lot for answering my questions that detailed (and excuse my wacky English skills :-)).
Meeting people like you justifies the whole traveling to San Francisco alone . . .
