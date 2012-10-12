---
layout: post
title: "The pain of a non Hypermedia HTTP API"
date: 2012-10-09 08:02
comments: true
categories: [social-network-api, hypermedia]
---

Last post I promised to talk about the WHY I'm interested in hypermedia in more detail. So let's start right from the beginning.

9 Month ago I joined the API team of [XING](http://www.xing.com). If you weren't aware that XING has an API, no biggie. That's likely because at the time of writing, we're still in a '[Closed beta](http://dev.xing.com)'. Although beta implies a brand new product, the API we're currently working on is actually a mature product which has been in place for several years now, though not available to the public. Basically if you're using one of our native apps, you've been consuming our API for quite a while now.

You might ask yourself why we're still in beta then. Well, that's a totally different story and, forgive me, one I can't elaborate on.

What matters for this post is that our current API design follows a similar approach to the ones known from [Facebook](http://developers.facebook.com/docs/reference/api/), [Twitter](https://dev.twitter.com/docs/api/1.1) or [GitHub](http://developer.github.com/v3/),  which is basically **Remote Procedure Call (RPC) over HTTP with extensive out of band documentation**. 

Pretty much everyone knows how to use such an API. Request in, response out, containing what looks like a serialized version of an object graph. If you don't understand the API, no problem at all, you can always look up the official documentation of the particular API call. Doesn't look like a complex problem, right?  Appearances can be deceiving ...

At least I thought it wasn't complex. You know, I have a special nickname for API development.  Having a nickname for something like that is probably already telling a lot.
The good thing about it is, that it constantly reminds me of my false assumptions when I came to API development.
{% pullquote left %} {"I call API development my personal Vietnam of Agility"}. The approach to building software I mostly used prior to joining my current team was mostly all about starting small, learn and adapt to a better solution. I used to build my software of loosely coupled parts, that made it easy to correct mistakes or false assumptions afterwards and **it's exactly that flexiblity or loose coupling that I currently miss most**.
{% endpullquote %}

Do you remember the movie *The Devil's Advocate* with Keanu Reeves and Al Pacino? If I recall correctly, there's a scene in that movie where the main actor (played by Reeves) signs a deal with his new employer (played by Pacino) and Pacino has this deceitful smile on his face, as if he knew something his opposite didn't. If you don't know the movie, I won't spoil the ending for you. Let's just say, both sides weren't happy with the contract in the end.

So what has this to do with public-facing RPC APIs over HTTP?
{% pullquote right %} As an API provider {"your public interface is a contract"}, a contract between you and your clients. What you basically say when you present such an API could be summed up like this (**Read this out loud, for a more dramatic effect**)
{% blockquote %}
I'll make sure that there won't be any breaking structural changes. I'm going to ensure that the URI scheme doesn't change either. If I've no other options than to break things, it's my responsibility to find a way that doesn't impact you much. You on the other hand, need to figure out how those API calls relate to each other. There's a wonderful part in the contract (the API documentation) which outlines how to do it. Go and read the f***ing manual! Of course, in order to use the API calls correctly, you have to replicate parts of our business logic for determining which calls can be used in what context.
{% endblockquote %}
{% endpullquote %}

If you're willing to aggree to such a contract, make sure to understand all the consequences of it. 

You're choices will impact the amount of coupling between your API and the clients consume it. Coupling that may prevent your API from evolving independently from your clients. 


Of course this exaggerated.

  - a lot upfront design
  - design for forward compatibility
  - nevertheless incompatible changes happen
    - removing calls
    - structural changes
  - Versioning
    - If so how?
    - Bulk?
- Discoverability, discovering new features
- Out of band documentation is necessary
  - Believe me when I say, no matter how hard you try, a majority of all the consumers won't even bother to read the documentation.
- constant fear of breaking things
- to make things just a bit harder, our team is sitting on top of a service oriented architecture.
