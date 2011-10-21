---
author: BjRo
date: '2009-01-21 17:39:15'
layout: post
slug: tales-from-hashes-null-and-boolean-evaluation
status: publish
title: Tales from hashes, null and boolean evaluation
wordpress_id: '214'
comments: true
footer: true
categories: [ruby]
---

A common programming situation when dealing with dictionary or hashtable
classes is trying to get a value from the hashtable and returning a
default value in case nothing was found. In C# you could probably do it
like this: 

``` csharp A StringMapper 
public class StringMapper : IMapper 
{
	private IDictionary<string, string> mapping; 
	
	public Mapper(IDictionary<string,string> mapping) 
	{ 
		this.mapping = mapping; 
	} 
	
	public string Map(string input) 
	{ 
		string output; 
		
		if(!this.mapping.TryGetValue(input, out output)) 
		{
			return "defaultValue"; 
		}
		
		return output; 
	} 
} 
```

You could write similar code in Ruby. 

``` ruby My first naive implementation in Ruby

class StringMapper

	def initialize(hash_map) 
		@hash_map = hash_map 
	end 

	def map(input)
		output = @hash_map[input] 
		return (output.nil?) ? "defaultValue" : output 
	end 
end
```
However the way the map method is written is not the way Ruby is intended to be used and how Ruby sources are
mostly written. You could rework this into this short fragment.

``` ruby A more ideomatic solution 
def map(input) 
	@hash_map[input] or "defaultValue" 
end 
```
You might yourself now ask (as I did) why this code works? It works because

1.  Ruby automatically treats the last evaluated expression inside a method as the return value. Because of that you're able to omit the return statements.
2.  `Nil` (the Ruby equivalent of C#s `null` ) is actually an instance, an instance of the `NilClass`). Yeah right, you have the Null-Object-Pattern in the language here :-)
3.  Every object instance can be evaluated to a boolean. Every instance other than an instance of the `NilClass` evaluates to an instance of
    the `TrueClass`. The only exception to this is of course `false`.
