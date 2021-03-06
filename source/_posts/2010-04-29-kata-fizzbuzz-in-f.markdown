---
author: BjRo
date: '2010-04-29 19:00:00'
layout: post
slug: kata-fizzbuzz-in-f
status: publish
title: Kata FizzBuzz in F#
wordpress_id: '797'
categories: [dotnet, FSharp, Katas]
comments: true
footer: true
---

Last F# book club meeting in Munich was awesome (as usual). 2 weeks ago we decided to do a Code Kata on each subsequent meeting. This week was our first, with Kata FizzBuzz.
<!--more-->This is what we came up with. (BTW: Partial function application and pipelining rocks !!!)

``` csharp Kata FizzBuzz in F#
open Xunit  

let fizzBuzz number =      
     match number with     
     | n when n%15=0 -> "FizzBuzz"     
     | n when n%3=0 -> "Fizz"    
     | n when n%5=0 -> "Buzz"    
     | _ -> number.ToString()  

let areEqual expected actual =      
     Assert.Equal(expected, actual)  

[<Fact>] 
let Should_return_the_digit_for_numbers_which_are_not_dividable_by_3_or_5()  =  
    [1;2;11;13;16]     
    |> List.map fizzBuzz
    |> List.iter2 areEqual ["1";"2";"11";"13";"16"]  

[<Fact>] 
let Should_return_Fizz_for_digits_dividable_by_3() =      
    [3;6;9;12]     
    |> List.map fizzBuzz      
    |> List.iter (areEqual "Fizz")

[<Fact>] 
let Should_return_Buzz_for_digits_dividable_by_5() =      
    [5;10;20;25]     
    |> List.map fizzBuzz      
    |> List.iter (areEqual "Buzz")  

[<Fact>] 
let Should_return_FizzBuzz_for_digits_dividable_by_3_and_5() =      
    [15;30;45;60]     
    |> List.map fizzBuzz      
    |> List.iter (areEqual "FizzBuzz")  
```

If anyone of you hardcore functional guys out there notices something utterly wrong or something that could radically simplified, please let me know. 
We’re eager to learn more.
