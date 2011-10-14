---
author: BjRo
date: '2010-04-19 08:48:46'
layout: post
slug: testing-f-code-with-xunit-net-on-net-4-0
status: publish
title: Testing F# code with xUnit.net (on .NET 4.0)
wordpress_id: '784'
categories: [dotnet, FSharp]
comments: true
footer: true
---
A lot of my free time currently goes into learning F#. 
While I had a great time playing around with the F# REPL FSI, I came to the conclusion that using FSI is not my 
preferred way of a) learning the F# language and b) to develop code. 
Writing unit tests simply for the purpose of learning and understanding of a language/component/system (aka &quot;Learning tests&quot;) seems to be a better fit, 
at least for me. So, I sat down in order to see how I can use my beloved xUnit.net for this. 
As it turns out it's not that difficult, but it's got some hurdles. 
<!--more-->

Possible runtime differences
----------------------------
xUnit.net 1.5 is compiled against the .Net Framework 3.5. If you're using F# in combination with the VS2010 RC or 
RTM (like I do) you've got at least to options to make them work together. 

- Use multi-targeting and configure the F# projects to compile for the .NET 3.5 runtime  (`Properties/Application/Target Framework`). 
- Update the app.config files of xunit.console.exe and xunit.gui.exe with a startup section and specify the .NET framework 4.0 version as supported.

``` xml Update the app config
     <startup>
    	<supportedRuntime version="v4.0.30128" safemode="true"/> <!-- VS2010 RC -->
    	<supportedRuntime version="v4.0.30319" safemode="true"/> <!-- VS2010 RTM -->
     </startup>
```

Pay attention to your parentheses
----------------------------------
My choice was to update the xUnit.net configurations. After the update of the configuration files my assembly was loaded, 
however the test runner failed to detect my unit tests. As it turns out the open parentheses after a test function play an important role.

```csharp
     [<Fact>]
     let After_converting_a_valid_data_row_the_title_should_have_been_extracted = //This compiles, but the test doesn't show up in the test runner.
        let row = convertDataRow "Test, 1234"
        Assert.Equal(fst(row), "Test")

     [<Fact>]
     let After_converting_a_valid_data_row_the_title_should_have_been_extracted() = //This will work fine
        let row = convertDataRow "Test, 1234"
        Assert.Equal(fst(row), "Test")
```

My first reaction was: WTF? But after reading some more chapters of &quot;Real world functional programming&quot; and a discussion at our 
local F# book club the behavior makes sense to me. My current understanding is that omitting the parentheses results in a different method signature. 
You can easily spot this in FSI:

- The first one is `val After_converting_a_valid_data_row_the_title_should_have_been_extracted : unit`
- The second one results in a `val After_converting_a_valid_data_row_the_title_should_have_been_extracted : unit -> unit` 

What you can see here is that the first function signature doesn't have a parameter while the second has a parameter of the type `unit`. 
One interesting difference between F# and C# is that the F# equivalent to C#'s `void` is an actual type called `unit`. 
The fun part is that `()` is it's only value. Parentheses play a completely different role here ;-) 

The xUnit test runner looks for methods with one unit parameter and a return type of unit. 
That's why you need the parentheses.

Testing exceptions with xUnit.Net
----------------------------------
One little subtlety I came across when testing exceptions is that you have to explicitly ignore the return value 
when you're using Assert.Throws and pass in a method which doesn't return unit. Feels a bit strange at first, but explainable. 
Again a signature mismatch. `Assert.Throws` expects a method with a `unit -> unit` signature. 
You have to do this in order to please the compiler. (If there's a better way for this, please let me know) 

``` csharp
    [<Fact>]
    let Trying_to_convert_an_invalid_format_throws() = 
        Assert.Throws(fun () -> convertDataRow "FuBar" |> ignore)
```

The ignore function simply throws away any value it receives, returns a unit and makes the F# compiler happy.

Conclusion
------------------------------
I hope you saw in this post that testing F# with xUnit.net is actually pretty easy. 
It's also a wonderful case for language interop on top of the CLR. Go see it for yourself :-)
