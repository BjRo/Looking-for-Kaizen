---
author: BjRo
date: '2010-02-25 20:51:37'
layout: post
slug: plain-old-clr-c-object
status: publish
title: Plain Old CLR / C# Object
wordpress_id: '779'
comments: true
categories: POCO
---
Crap, time can go by so fast. On Monday a [tweet](http://twitter.com/ralfw/status/9446904971) by **Ralf Westphal** caught
my attention and I felt the need to comment. It started as a series of Twitter replies, but to be honest Twitter isn’t suited or made for those kind of discussions.
So I started to write this post in order to explain why I disagree with Ralf (or at least don’t get the intended message of his tweet). 
Yeah a short look into the calendar indicates that I’m a little late, but I thought better late than ditch the post and forget about it.  

What got me baffled
--------------------
In his tweet he basically states (my translation from German to English) that   

{% blockquote Ralf Westphal http://twitter.com/ralfw/status/9446904971 %}
If a domain model consists only of POCOs it should be called data model
{% endblockquote %}

My first thought was a) does he mean anemic domain models and b) what has POCO to do with that? As I found out he didn’t mean
[anemic domain models](http://twitter.com/ralfw/status/9493173442). So let’s take a look at the POCO aspect.
<!--more-->

POCO / POJO / PONO / POwhatever
---------------------------------
The term exists in several variations and different programming languages. For the sake of simplicity I’m going to use POCO for the rest of the post since
I’m a .NET guy, but same applies of course to all other versions.
The English [Wikipedia site](http://en.wikipedia.org/wiki/Plain_Old_CLR_Object) defines the term “Plain Old CLR Object” as the
following:   
{% blockquote Wikipedia http://en.wikipedia.org/wiki/Plain_Old_CLR_Object %}
The term is used to contrast a simple object with one that is designed to be used with a complicated, special object frameworks such as an ORM component. 
Another way to put it is that POCO's are objects unencumbered with inheritance or attributes needed for specific frameworks …  
{% endblockquote %}

To me personally, POCO is just a simple, but very important principle or guideline. POCO for me means,
that you should strive to limit the contact area of your own code and the code of third party frameworks as much as possible.
This includes staying away from third-party frameworks with heavy attribute usage and / or inheritance requirements. 
Why should you do this? 2 reasons seem to be important to me:

- **Orthogonality**. Two parts of a system, like features, components, classes, whatever are called orthogonal when changes in one don’t affect the other. 
Following a POCO approach in a solution can greatly support orthogonality in my personal experience. It helps you to design and build solutions that are easy to change and very adaptable to new requirements or frameworks 
(Ever tried to migrate a Microsoft CAB based solution?). Which leads to the second IMHO very important aspect:      
- **Reversibility**. In the end of the day we’re all human. Sometimes we design the wrong way, sometimes the framework doesn’t work as expected, 
sometimes a particular framework isn’t exactly the right one any more when requirements change drastically. 
All those things happen. All those things can can come up in any project. POCO can help a lot in those situations, 
because it limits the impact of external frameworks or components to your code. 

POCO mostly comes up in the context of an ORM solution. However, the concept of POCO is not directly bound to persistence or even domain models.
Which leads me back to the entry of the post and Ralfs tweet. What is the main distinction between a domain model and something we might call a data model?
In my opinion this is BEHAVIOR. The term POCO itself has nothing to do with behavior itself (at least from my perspective). 
Totally different aspects IMHO. So why should a model consisting of POCOs be called data model?    

Am I fighting on lost ground here, missing something or confusing something?
