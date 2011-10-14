---
author: BjRo
date: '2009-01-21 17:39:15'
layout: post
slug: tales-from-hashes-null-and-boolean-evaluation
status: publish
title: Tales from hashes, null and boolean evaluation
wordpress_id: '214'
? ''
: - C#
  - C#
  - Ruby
  - Ruby
---

A common programming situation when dealing with dictionary or hashtable
classes is tryingÂ to get a value from the hashtable and returning a
default value in case nothing was found. In C\# you could probably do it
like this: [sourcecode language="csharp"] public class StringMapper :
IMapper { private IDictionary mapping; public Mapper(IDictionary
mapping) { this.mapping = mapping; } public string Map(string input) {
string output; if(!this.mapping.TryGetValue(input, out output)) { return
"defaultValue"; } return output; } } [/sourcecode] You could write
similar code in Ruby. [sourcecode language="Ruby"] class StringMapper
def initialize(hash\_map) @hash\_map = hash\_map end def map(input)
output = @hash\_map[input] return (output.nil?) ? "defaultValue" :
output end end [/sourcecode] However the way the map method is written
is not the way Ruby is intended to be used and how Ruby sources are
mostly written. You could rework this into this short fragment.
[sourcecode language="Ruby"] def map(input) @hash\_map[input] or
"defaultValue" end [/sourcecode] You might yourself now ask (as I did)
why this code works? It works because

1.  Ruby automatically treats the last evaluated expression inside a
    method as the return value. Because of that you're able to omit the
    return statements.
2.  *Nil* (the Ruby equivalent of C\#s *null* ) is actually an instance,
    an instance of the *NilClass*). Yeah right, you have the
    Null-Object-Pattern in the language here :-)
3.  Every object instance can be evaluated to a boolean. Every instance
    other than an instance of the *NilClass* evaluates to an instance of
    the *TrueClass*. The *NilClass* is the only class I met so far which
    evaluates to an instance of the *FalseClass*.

