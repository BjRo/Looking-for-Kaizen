---
author: BjRo
date: '2010-05-12 19:36:38'
layout: post
slug: kata-stringcalculator-in-f
status: publish
title: Kata StringCalculator in F#
comments: true
wordpress_id: '803'
categories: [FSharp, Code Kata, StringCalculator]
footer: true
---

Yesterday's F# bookclub meeting in Munich was awesome as usual. It’s very interesting to see our overall understanding of functional programming progressing. 
Slowly, but steady. Main topics we discussed on the last meeting were Currying and Tail Recursion. Finally "got that" (at least I think so ;-))

Two meetings ago we decided to do some coding on every meeting. The previous meeting we solved Kata FizzBuzz and on yesterday’s meeting we tried to dance with 
[Roy Osheroves StringCalculator](http://osherove.com/tdd-kata-1/). We didn't make it completely to the end, but I think we solved most of the Kata. 
You can find yesterdays code at the end of this post. I'm sure in parts it smells a bit imperative and it definitely uses too much Regex - KungFu, 
but overall I'm pleased with the result. 

We've tried to incorporate the feedback we got on the Kata FizzBuzz code. I would love to get feedback on this one as well. 
What could be done better, cleaner or simply differently?

``` csharp Kata StringCalculator in F#
open System
open System.Text.RegularExpressions
open Xunit

let shouldBeEqualTo a b = Assert.Equal(a,b)

let parse value =
    if String.IsNullOrEmpty(value) then 0 else
    match Int32.TryParse value with
    | (false,_) -> failwithf "Did not parse value %s" value  
    | (true, n) when n < 0 -> failwithf "Negatives not allowed %s" value
    | (true, n) when n >= 1000 ->0
    | (true, n) -> n

let splitIntoDelimitersAndRest (calculationString:String) =
    let defaultDelmiters = [",";"\n"]
    let regex = new Regex("^//(?<defaultDelimiter>.*?)\\n(?<rest>.*)$", RegexOptions.Singleline)
    match regex.Match calculationString with
    | m when m.Success ->
        let delimiters = List.Cons(m.Groups.["defaultDelimiter"].Value, defaultDelmiters)
        (delimiters, m.Groups.["rest"].Value)
    | _ -> (defaultDelmiters, calculationString)

let add (calculationString:String) =
   let splitResult = splitIntoDelimitersAndRest calculationString
   let delimiters = fst splitResult |> List.toArray
   let rest = snd splitResult
   rest.Split(delimiters, StringSplitOptions.RemoveEmptyEntries)
   |> List.ofSeq
   |> List.map parse
   |> List.sum

[<Fact>]
let ``When an empty string is supplied it should return 0``() =
    String.Empty
    |> add
    |> (shouldBeEqualTo 0)
 
[<Fact>]
let ``When a single digit is supplied it should return the digits value``() =
    ["1"; "2"; "3"]
    |> List.map add
    |> List.iter2 shouldBeEqualTo [1;2;3]
 
[<Fact>]
let ``When two digits are supplied separated by a comma it should be able to some them up``() =
    ["1,2"; "3,4"; "4,5"]
    |> List.map add
    |> List.iter2 shouldBeEqualTo [3;7;9]

[<Fact>]
let ``When more than two digits are supplied separated by a comma it should be able to sum them up``() =
    ["1,2,4,5"; "3,4,5"; "4,5,6,7,8"]
    |> List.map add
    |> List.iter2 shouldBeEqualTo [12;12;30]

[<Fact>]
let ``When more than two digits are supplied separated by new line character be able to to sum them up``() =
    ["1\n2\n4\n5"; "3\n4\n5"; "4\n5\n6\n7\n8"]
    |> List.map add
    |> List.iter2 shouldBeEqualTo [12;12;30]
 
[<Fact>]
let ``When more than two digits are supplied separated by new line character or comma it should be able to some them up``() =
    ["1,2\n4,5"; "3,4\n5"; "4,5\n6\n7\n8"]
    |> List.map add
    |> List.iter2 shouldBeEqualTo [12;12;30]
 
[<Fact>]
let ``When more than two digits are supplied separated by a user supplied default delimiter it should be able to sum them up``() =
    ["//*\n1*2*4*5"; "//$\n3$4$5"; "//%\n4%5%6%7%8"]
    |> List.map add
    |> List.iter2 shouldBeEqualTo [12;12;30] 

[<Fact>]
let ``When more than two digits are supplied separated by a user supplied default delimiter or one of the standard delimiters it should be able to sum them up``() =
    ["//*\n1*2*4*5"; "//$\n3$4$5"; "//%\n4\n5%6%7%8"]
    |> List.map add
    |> List.iter2 shouldBeEqualTo [12;12;30]
 
[<Fact>]
let ``When digits greater than 1000 are supplied it should ignore them``() =
    ["//*\n1*2000*4*5"; "//$\n3$4$1000"]
    |> List.map add
    |> List.iter2 shouldBeEqualTo [10;7]

[<Fact>]
let ``When using more than two digits with with a custom separator of multiple characters ít should be able to sum them up``() =
    ["//asdf\n1asdf4asdf5"; "//as\n3as4as"]
    |> List.map add
    |> List.iter2 shouldBeEqualTo [10;7]
```
