---
layout: post
title: "Fighting coupling, let the games begin!"
date: 2012-11-12 19:20
comments: true
categories: [social-network-api, hypermedia]
---
I had almost forgotten what a writers block feels like over the past 1 1/2 years. Unbelievable how hard it sometimes is for me to put thought into words that I feel comfortable with. Or maybe I'm just hypercritical with myself. I don't know. Whatever the reason, this is my 5th attempt to write this goddamn blogpost and this time I intend to finish it. 

Last time we ended up with my realization that a typical 'RPC over HTTP' API can have some serious downsides when used for a public facing API, namely tight coupling between the client and server side. Coupling which will likely result in an overall hard to change and hard to evolve distributed system in the long run. The question is, what can we do against that? How can we reach a state were the server and client can evolve independently without stepping on each others toes?

Judging from what I've learned so far from the Hypermedia guys, there are solutions to this problem. Some of them may not sound super intuitive at first glance, especially in contrast to the wellknown RPC approach. But be warned, they definitely require changed behavior in clients. Without a change in how clients work with an API the whole idea falls apart. There are certainly different shades of implications for the client, depending on how conform a client wants to be with the new rules, but he has to change nevertheless. If you disagree with that, save your time. You can stop reading this post!

So what is our battleplan? How can we turn our RPC approach into something with less coupling? The short answer is: **By systematically reducing the amount of necessary out-of-band information**.

I can almost here you shouting out 'What is that supposed to mean?'. 'out-of-band information' is that kind of information which isn't present in the API itself, but is necessary to work with the API. It's a synonym for 'external documentation' or in other words nearly every question you answer politely with 'RTFM'. Coincidently the stuff that's typically hardcoded in clients: URLs, data structures, parameters, response codes and relationships between API calls.** We need to make this information available to a client as part of the API**.  

In the best possible scenario all a client should need to know is the root url of the API. Everything else should be available via the API itself. Ok, I'm getting ahead of myself here. Let's start a bit smaller. How could we enhance a pure HTTP RPC API to reduce coupling? 

We're going to start by making larger parts of the documentation available as a dedicated resource at the root URL of the API, a [home document](http://tools.ietf.org/html/draft-nottingham-json-home-02).

```
GET / HTTP/1.1
Host: example.org
Accept: application/json-home

HTTP/1.1 200 OK
Content-Type: application/json-home
Cache-Control: max-age=3600
Connection: close

{
 "resources": {
   "http://example.org/rel/widgets": {
     "href": "/widgets/"
   },
   "http://example.org/rel/widget": {
     "href-template": "/widgets/{widget_id}",
     "href-vars": {
       "widget_id": "http://example.org/param/widget"
     },
     "hints": {
       "allow": ["GET", "PUT", "DELETE", "PATCH"],
       "representations": ["application/json"],
       "accept-patch": ["application/json-patch"],
       "accept-put": ["application/json"]
       "status": "obsolete"
     }
   }
 }
}
```
The request for the root URL of our API would return a heavily cachable sitemap for the API, containing detailed information about each resource in the API. If you're wondering what those keys in the resources JSON object are, they're link relations as described in [RFC5988](http://tools.ietf.org/html/rfc5988). In my own words I would describe them as global identifiers for resources. They play an important role in the greater scheme. 

We talked briefly about changed rules for a client, this is one of them. If a client wants to relax his coupling to the API, he shouldn't bind to URLS directly and bind to link relations instead. Using a link relation he is able to obtain the information needed to construct a request from the home document.

Well that sounds like a good place to stop for today. Next time we dive into some code and take a look at how such a home document might feel in real life. If you're curious, I've already implemented the [server part](https://github.com/BjRo/social-network-api/blob/master/social-network-server/spec/controllers/home_document_controller_spec.rb) for this.
