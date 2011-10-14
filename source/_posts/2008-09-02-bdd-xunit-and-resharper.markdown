---
author: BjRo
date: '2008-09-02 18:01:19'
layout: post
slug: bdd-xunit-and-resharper
status: publish
title: BDD, xUnit and Resharper
wordpress_id: '111'
? ''
: - BDD
  - BDD
  - Testing
  - Testing
  - Uncategorized
  - Uncategorized
  - xUnit
  - xUnit
  - BDD
  - BDD
  - Resharper
  - Resharper
  - xUnit
  - xUnit
---

Yesterday was an interesting evening. I tried to pinpoint the problem
between the little BDD framework I used and the Resharper addin for
xUnit. **A short description of my problem** I'm using a
test-case-class-per-fixture organization and the template method pattern
for writing tests in the AAA scheme. Besides that I use a specialized
*FactAttribute*in order to invoke my AAA - hook methods in the correct
order. All of this is residing in a separate assembly. When I use the
build-in FactAttribute to mark my tests alll tests are discovered by the
Resharper's TestExplorer, but when I'm using my own marker attributes
nothing is discovered. **What seems to be the problem** It took me some
time to find out what was actually going on. I've never debugged a
Resharper-Plugin before.
[This](http://www.jetbrains.net/confluence/display/ReSharper/Building,+running+and+debugging+plugin)
helped a lot. It was an interesting experience, though. Didn't knew that
there is so much going on behind the scenes. This is what I found out:

-   The XUnitTestProvider class is responsible for discovering tests.
-   It skips all assemblies which don't reference xunit directly.

Hm, I had a reference to xunit in my test library project settings.
However I was not referencing xUnit stuff from my code directly (Own
FactAttribute and xunitext35 extension methods for assertions). That's
when it hit me: My problem was probably caused by a compiler
optimization. It seems that all unused assembly references are removed
when building the test assembly. A look into reflector supported my
thesis. So my test assembly has no direct reference to the xunit.dll,
only an indirect one through the BDD framework. **Patching this is quite
easy** This is the original method: [sourcecode language="Csharp"]
static bool IsTestAssembly(IMetadataAssembly assembly) { foreach
(AssemblyReference reference in assembly.ReferencedAssembliesNames) if
(reference.AssemblyName.Name.ToLowerInvariant() == "xunit") return true;
return false; } [/sourcecode] When changing this a bit to this,
everything runs as expected. [sourcecode language="Csharp"] static bool
IsTestAssembly(IMetadataAssembly assembly) { foreach (AssemblyReference
reference in assembly.ReferencedAssembliesNames) { string assemblyName =
reference.AssemblyName.Name.ToLowerInvariant(); if
(assemblyName.StartsWith("xunit")) return true; } return false; }
[/sourcecode] All tests are discovered and I'm quite happy that I can
use BDD, XUnit and Resharper in combination :-) One thing to be aware
of: In order to get the tests not only discovered but also executed in
Resharper you'll have make sure that your test project and the Resharper
addin are both using the same, exact version of xUnit. I stumbled over
this after I recompiled and installed my patch on my machine. Resharper
is not able to execute the tests in case of a version mismatch.
