---
layout: post
title: "Join me on a journey"
date: 2012-10-05 19:01
comments: true
categories: [social-network-api, hypermedia]
---
In the last couple of months I've been reading, listening to and watching everything I could find or buy about REST and Hypermedia. I think I've now come to a point where the only logical continuation of this learning process is to try to apply what I've learned so far to an actual problem.

** It's time to stop talking theoretically.** I really badly want to see a 'real world' example of those concepts in play. I want to experience the impact of such a design first hand, both  on the server and on the client side as well.

I've been carrying this idea with me for several days now and finally decided to give in.

** So here's what I would like to do: **

- I'm going to try myself on designing a **Hypermedia API for a social network** from scratch. This will include the whole state machine / sitemap design for a small subset of the typical features of a social network. I'm thinking about profiles, contacts and private messages for a start, but that's not set.

- I will document the whole process of evaluating existing media types vs. the creation of a new vendor specific one for the API.

- I'm going to implement the API iteratively, starting with an MVP and then adding more and more features as we go along, documenting every step on the way here on this blog.

- I will throw in some nasty real world requirements I've encountered first hand while working on one of the larger HTTP APIs available in Germany.

- Last but not least, I want to also explore what Hypermedia means for the client side and this both in a statically and in a dynamically typed language.

You might ask yourself what my motivation behind all this is and I promise you, I will elaborate on that in detail, but not in this post. For the moment let's just say, I currently tend to think Hypermedia would make parts of my professional life easier. Not sure how much this is going to be in the end, but hey, let's just find out!

**Please note the following:** I don't consider myself an expert on this topic. This is a learning exercise for me as well. I'm very likely to stumble on my way. If I do, I thought my chances for getting up again and continuing this journey would improve a lot with outside feedback and help. 

That's the main reason why I'm doing this out in the open. The source code repository for this can be found [here](http://www.github.com/bjro/social-network-api). Feel free to watch it, fork it and/or to contribute. I don't know how long this all will take me and I can't guarantee you a regular schedule for updates, but I'm committed to make this work. Hopefully we'll see this page getting updated frequently with new content.

So, what do you think? Are you in?

-Bjoern

## Table of contents

1. [My pain with a non Hypermedia HTTP API](/2012/10/16/the-pain-of-a-non-hypermedia-http-api/)
2. [Fighting coupling, let the games begin!](/2012/11/12/fighting-coupling/)
