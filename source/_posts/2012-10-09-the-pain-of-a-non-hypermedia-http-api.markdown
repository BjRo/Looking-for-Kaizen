---
layout: post
title: "The pain of a non Hypermedia HTTP API"
date: 2012-10-09 08:02
comments: true
categories: [social-network-api, hypermedia]
---
- Have been working for the last 9 month in the XING API team
- HTTP based RPC API
- Currently about 14 Billion requests per day
- RPC seems easy, but looks are often deceiving
  - There's the binding aspect
    - Contract between you and the consumer
    - If not defined basically says something like this is all for granted
    - Nothing is going to change
- vietnam of agility
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
