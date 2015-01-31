---
layout: post
title: "Hypermedia or not to Hypermedia"
date: 2015-01-31 18:15:19 +0100
comments: true
categories: [hypermedia]
---
Ask 10 people to describe what they think REST is and you likely get 10 different answers. For some it's 'only' HTTP APIs. Other extend this to CRUD over HTTP and fancy urls. Some talk of Hypermedia and always end up quoting [Inigo Montoya](http://knowyourmeme.com/memes/you-keep-using-that-word-i-do-not-think-it-means-what-you-think-it-means). What's THE right way to build HTTP APIs? Who of them is right and who is wrong?

I've been in those discussions for long enough with colleagues to actually put the 'fruitless' stamp on it.  Maybe it's just resignation or perhaps I'm some years older now and a bit relaxed on some topics. Who knows? I can't help to think though, that often we approach those kind of questions from the wrong angle.  Maybe instead of asking 'what is the right way to build REST APIs?' we should more ask other types of questions instead, that might give the questioner a better understanding of the trade-offs involved in designing an API. I usually use some of these questions, to explore options:

* who will consume the API?
* how many consumers are there?
* how often is change expected in the API?
* what kind of change is expected in the API?
* is cheaply changing the API important?

Finding answers to these questions for me is very insightful and can change the route I take or the advice I usually give regarding REST APIs. The underlying idea here is to figure out how loosely coupled the contract between the consumer of the API and the provider of the API needs to be. 

Coupling itself is a strange beast to describe, but for me it often correlates with pain and effort to change something. The higher the pain is when you attempt to change something, in my experience, the likelier it is that you're dealing with tight coupling. Pain in this context can mean a whole variety of things and ranges from "I added a new type in my JSON response and boom, our mobile app crashes" over "in order to use the new feature we will have to update all of the consumers" to "this will take a lot of coordination and time to make it happen". I guess everyone who has worked on some form of library or API-providing-service over a longer period of time has experienced some form of pain because of coupling. Trying to be agile and iterate on ideas quickly with a tightly coupled system is almost like rock climbing, only with your feet in buckets of cement and your wrists handcuffed. Probably not something you'll fondly remember.

From my point of view real hypermedia enabled REST APIs are all about enforcing loose coupling. I don't think though, that every HTTP API needs a loosely coupled design. Some APIs benefit more than others from Hypermedia and in some contexts it might not be worth to go down the Hypermedia route because of the cost/benefit ratio.

#When do I prefer Hypermedia?
The more you get to the edges of your platform and your control, the likelier it is that Hypermedia makes sense. This statement includes two things:

* if you have a SOA or you are on the road to microservices and you are still able to change both sides in a reasonable amount of time, not going down the hypermedia route is perfectly fine for me.
* Integration points with consumers you can't change in a reasonable amount of time (for instance native mobile apps) are a different beast and require special attention.

##Not for public APIs
Public APIs like the one provided by Linkedin, Facebook, XING et al fall under the second category, but **I don't think they're a good candidate for Hypermedia**. They usually have a very low change frequency (people outside your company are not so fond to upgrade the integration of your API every second week ^^) and are often designed to be dead easy to use (anybody who can spell 'Curl' should be able to use it). In the absence of established standard media types and widely available hypermedia enabled libraries, at least at the moment, Hypermedia doesn't bring a lot benefit for that to the table.

##When native apps are involved
Native mobile apps on the other hand are more worth the effort of Hypermedia. I'm pretty convinced that in a competitive mobile marked the ability to have fast feedback cycles is a key differentiator. We had the cool web, where we could enhance the product anytime we want, where fixing bugs didn't require rolling out a new version of the software, but unfortunately for us poor developer-souls the industry moved back to more traditional software release models. We can loudly complain about that, but I think it's also part of our job to deal with that as best as we can.

Hypermedia as a concept is actually a pretty decent approach for not falling back to the way software was developed and released 10-20 years ago. Think of old versions of your mobile apps that automatically disable functionality that has been deprecated. Think about new functionality appearing in already shipped mobile apps without having to roll out new versions of the native apps. Try to imagine a world where APIs not only act as the data provider for a mobile app, but more like an engine powering them. 

I really like that view on the mobile / backend integration, but I'm not naive. Bringing Hypermedia into existing apps is not an all-or-nothing approach. Some areas of a native app benefit more than others from Hypermedia. That's the area worth investing. Use it where it matters the most.

To give you a real world example, this is what we've done when we re-designed the XING mobile activity feed last year. An area where change is constant and new content types are added frequently. In the past this required a lot of coordination between multiple teams and about 3 months to release new content. Nowadays we only need two weeks for adding new content types and nearly all of the work is done in the backend. 

I call that a success
