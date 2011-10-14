---
author: BjRo
date: '2009-01-19 19:12:05'
layout: post
slug: using-rake-to-automate-net-builds
status: publish
title: Using Rake to automate .NET builds
wordpress_id: '208'
? ''
: - Rake
  - Rake
  - Ruby
  - Ruby
  - xUnit
  - xUnit
---

Today I started writing my first build scripts in Ruby for a .NET
project using Rake. This is what I came up with. [sourcecode
language="ruby"] require 'rake/clean' EXTERNALS\_DIR =
File.expand\_path('../Externals') BUILD\_DIR =
File.expand\_path('../Bin') SOURCE\_DIR = File.expand\_path('../Source')
CLEAN.include(FileList[File.join(BUILD\_DIR, '\*')]) desc "Compiles the
gemini sources" task :build do gemini\_solution = File.join(SOURCE\_DIR,
'Gemini.sln') sh "msbuild
/property:WarningLevel=4;OutDir=\#{BUILD\_DIR}/ \#{gemini\_solution}"
end desc "Runs all the tests on the gemini code" task :test do
assemblies = all\_spec\_assemblies() xunit\_console =
File.join(EXTERNALS\_DIR, "xUnit/xunit.console.exe") assemblies.each do
|assembly| sh "\#{xunit\_console} \#{assembly} /html \#{assembly
+'.UnitTests.html'}" end end task :default =\> [:clean, :build, :test]
def all\_spec\_assemblies() file\_mask = File.join(BUILD\_DIR,
'\*Specs.dll') FileList[file\_mask] end [/sourcecode] I think this code
demonstrates the qualities of Ruby as a scripting language and Rake as a
build tool really well. It's very descriptive and even more important it
doesn't have all the xml-slash-what-the-hell-is-going-on-here-noise
around it. I know it's a very simple solution, but I consider it a good
start. Let's look a bit more detailed at the parts of the script.

[sourcecode language="Ruby"] EXTERNALS\_DIR =
File.expand\_path('../Externals') BUILD\_DIR =
File.expand\_path('../Bin') SOURCE\_DIR = File.expand\_path('../Source')
[/sourcecode] This part defines some directory constants that are used
in the script. The rakefile is currently run from the directory 'Build'
which is on the same level as 'Externals', 'Bin' and 'Source'. Relative
paths are expanded to absolute paths here. [sourcecode language="Ruby"]
CLEAN.include(FileList[File.join(BUILD\_DIR, '\*')]) [/sourcecode] This
tiny little code piece modifies the built-in :clean task and adds all
files under the BUILD\_DIR to it. Running 'rake clean' on the console
will now delete all files from our build directory. [sourcecode
language="Ruby"] desc "Compiles the gemini sources" task :build do
gemini\_solution = File.join(SOURCE\_DIR, 'Gemini.sln') sh "msbuild
/property:WarningLevel=4;OutDir=\#{BUILD\_DIR}/ \#{gemini\_solution}"
end [/sourcecode] This is the first task I've actually written on my
own. It's only a very small wrapper around msbuild that builds the
solution file. [sourcecode language="Ruby"] desc "Runs all the tests on
the gemini code" task :test do assemblies = all\_spec\_assemblies()
xunit\_console = File.join(EXTERNALS\_DIR, "xUnit/xunit.console.exe")
assemblies.each do |assembly| sh "\#{xunit\_console} \#{assembly} /html
\#{assembly +'.UnitTests.html'}" end end def all\_spec\_assemblies()
file\_mask = File.join(BUILD\_DIR, '\*Specs.dll') FileList[file\_mask]
end [/sourcecode] That little code is a small wrapper around xUnit.net
which invokes the xunit.console.exe for each file it finds in the build
directory that ends with 'Spec.dll'. These are the assemblies which
contain the BDD-style tests in our project. [sourcecode language="Ruby"]
task :default =\> [:clean, :build, :test] [/sourcecode] This last piece
defines the :default build task. That's the task which is run when you
don't specify a task directly when running rake from console. This will
run all tasks in the order specified from left to right.

**Conclusion**

The Rake build engine rocks !!! Its really simple and descriptive API is
fun and Rake doesn't create a lot of ceremony around build scripts (Only
around 30 lines of code in my current script). However, you should be
aware of one thing: Coming from a language with a lot of IDE support
(like C\# in my case) to Ruby might not be as easy as it sounds. It took
me quite a while to make the transition from Intellisense and Resharper
to using IRB and reading RDoc in order to explore new APIs . . .
