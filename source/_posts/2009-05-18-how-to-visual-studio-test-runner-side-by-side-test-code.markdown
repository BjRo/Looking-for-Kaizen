---
author: BjRo
date: '2009-05-18 22:34:49'
layout: post
slug: how-to-visual-studio-test-runner-side-by-side-test-code
status: publish
title: 'How to: Visual Studio test runner & side by side test code'
wordpress_id: '337'
? ''
: - MSTest
  - MSTest
  - Testing
  - Testing
  - MSTest
  - MSTest
  - Testing
  - Testing
---

After spending a lot of time with xUnit.net I recently had to go back to
MSTest for my testing again (because it's the de facto standard at my
current client which is not negotiable ;-().

Former colleagues of mine will probably laugh about this, because I've
had a love-and-hate-relationship with MSTest and especially the
VisualStudio runner in the past. I won't go into details here, but you
can read about it [here](http://www.bjoernrochel.de/tag/mstest/).
However since I currently have no other option I use what is there.
Better writing tests such an environment, than writing no test at all.
At least if you ask me.

This brings me back to the topic of the post. Some prerequisites: I like
developing software in a TDD manner and am using Resharper with its
'Generate' and 'Move To' features a lot. I like the idea of having
test-code side by side with the actual tested code. With this a lot of
you're daily TDD life becomes at least a bit easier and painless. I see
at least two advantages in such an approach:

1.  You don't have to copy generated classes from the test-assembly to
    the regular assembly.
2.  You don't have to maintain two different folder hierarchies (The one
    in the code-assembly and the one in the regular assembly) and
    therefore know exactly where to look for test-code.

This is one of the things I learned from JP Boodhoo in his NBDN
bootcamp, credit for the general idea goes to him for this. So how can
we achieve this in VisualStudio with MSTest?

DISCLAIMER: The stuff I describe in the rest of the post has to do with
modifying the .csproj '“ msbuild file of a project. If this is a 'no go'
for you, you can probably stop reading here ;-). For the rest here is
the list of steps I took in order to make it work:

**Step 1: Add the ProjectType Guids to your project.**

VisualStudio's test explorer scans only projects which are of a certain
project type (aka the test project) for tests. VS identifies such a
project based on the value of a particular node in the .csproj file, the
*ProjectTypeGuid* node. Simply copy this one from an actual test project
to the .csproj of your regular assembly. Another option of course would
be to start with a test project from scratch. [sourcecode
language="xml"] Debug AnyCPU 9.0.30729 2.0
{3AC096D0-A1C2-E12C-1390-A8335801FDAB};{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}
{890DA3CA-999A-474E-BA87-05A834CAB7B8} Library Properties SpecReport
SpecReport v3.5 512 [/sourcecode] **Step 2: Apply conditional
compilation for not including the test code when compiling in release
mode**

So, the tests sit right next to the tested code, right? We presumable
don't want our tests to be deployed to production. We can achieve this
in MSBuild fairly easy with conditional compilation and wildcards.
[sourcecode language="xml"] [/sourcecode] **Step 3: Apply conditional
compilation for not deploying the test-related assemblies when compiling
in release mode**

In order to get rid of the test-specific assemblies for production
deployment you can also apply conditionals to the assembly references of
a project. [sourcecode language="xml"] False
..\\Externals\\RhinoMocks35\\Rhino.Mocks.dll 3.5 3.5 3.5 [/sourcecode]

Et voila: The approach described in this post seams to work fine. At
least I'm not experiencing side effects since I've configured it that
way ...
