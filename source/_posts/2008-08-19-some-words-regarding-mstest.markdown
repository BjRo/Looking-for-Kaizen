---
author: BjRo
date: '2008-08-19 21:41:50'
layout: post
slug: some-words-regarding-mstest
status: publish
title: Some words regarding MSTest
wordpress_id: '22'
? ''
: - MSTest
  - MSTest
  - MSTest
  - MSTest
  - Testing
  - Testing
---

Today I stumbled again about this and feel (once more) a bit frustrated
about the current version of **MSTest**. In theory Visual Studio VS2008
supports Test-Class-Inheritance. Once you actually start using it, you
pretty fast encounter one big limitation: **The test base class must be
in the same assembly as the derived test** Mh,Â is that such an uncommon
scenario that it's not supported? Personally I don't think so. What
about BDD extensions for MSTest? Do I need to have a Specification-base
class in each test assembly? Oh, c'mon ?! Just when you think it can't
get worse, you realize that **Tests using Test-Class-Inheritance are NOT
EXECUTED when running inside a VS TFS 2008 TeamBuild** Awesome :-(
Besides that we also still have the \*.vsmdi-hell (Replace \* with the
name your Solution and a number between 1 and 100 . . .), but that a
different story. If it was my personal decision I would ditch MSTest
right away. It'll be interesting to see whether I'm able to convince our
development leads to go down that road . . .
