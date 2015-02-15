---
layout: post
title: "SDK over API: the Good, the Bad and the Ugly"
date: 2015-02-15 14:51:21 +0100
comments: true
categories: [hypermedia]
---
In the last post I talked about the areas where Hypermedia or HATEOAS makes sense for me personally.
In general I tend to favor solutions following the Hypermedia ideas, where quick feedback loops are
a necessity and propagating changes through a system otherwise would take a lot of time. A good example
for this are native mobile apps on top of APIs.

Today I would like to extend the discussion a bit and include SDKs into the picture, but first let
us limit the scope of the post a bit.

# Scope
SDK is short for 'Software Development Kit' and a widely used term for describing tools, applications
and documentation around a product that simplify building software with or on top of it. I'm not talking
about SDKs in general here, but rather about the value of SDKs over public or semi-public APIs of a product.

# The Good
A web based product can benefit quite a bit when there's also an SDK available for it.
SDKs are a good tool for opening up a product and making it accessible for the less technically skilled
integrators, as they mostly abstract the tough parts of an API away from the consumer and instead
provide a clean, easy to use interface in the programming language of choice. Integrating with
a product, if you view it this way, just boils down to filling out the blanks.

They are also, like public APIs, a stability promise to their consumers. Being easy to use and to maintain
also very often implies a very low change frequency.
