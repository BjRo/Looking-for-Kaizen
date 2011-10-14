---
author: BjRo
date: '2009-01-27 14:48:54'
layout: post
slug: ilmerge-and-rake-go-xunitbddextensions
status: publish
title: ILMerge and Rake go xunit.BDDExtensions
wordpress_id: '253'
? ''
: - Rake
  - Rake
  - Ruby
  - Ruby
  - Rake
  - Rake
  - Ruby
  - Ruby
  - xUnit
  - xUnit
  - xUnit.BDDExtensions
  - xUnit.BDDExtensions
---

Today I added this little piece of code to the trunk of
xUnit.BDDExtensions. It's a rake task for merging assemblies via the
ILMerge tool.

[sourcecode language="Ruby"] desc "Merges the assemblies" task :merge do
mkdir DEPLOY\_DIR unless File.exists?(DEPLOY\_DIR) cp
"xunit.dll".expand\_to(:build\_dir),
"xunit.dll".expand\_to(:deploy\_dir) cp
"Rhino.Mocks.dll".expand\_to(:build\_dir),
"Rhino.Mocks.dll".expand\_to(:deploy\_dir) assemblies\_to\_merge =
["xUnit.BDDExtensions.dll", "StructureMap.dll",
"StructureMap.AutoMocking.dll"] ilmerge "xunit.bddextensions.dll",
assemblies\_to\_merge end [/sourcecode]

Ruby is a fantastic language. The more I learn about it the more I
actually like it. Let's have a look at how this task is implemented.
First of all I opened up Ruby's string class and added new methods to it
(this is called MonkeyPatching, and worth a blog post on its own :-))

[sourcecode language="Ruby"] class String def escape
"\\"\#{self.to\_s}\\"" end def expand\_to dir\_symbol case dir\_symbol
when :build\_dir path = BUILD\_DIR when :source\_dir path = SOURCE\_DIR
when :externals\_dir path = EXTERNALS\_DIR when :deploy\_dir path =
DEPLOY\_DIR end File.join(path, self.to\_s) end end [/sourcecode]

And here is the actual *ilmerge* - method. It simply gets the complete
path to the ILMerge.exe (not shown here), expands the name to all
assemblies that have to be merged and escapes them, before the actual
call to ILMerge is issued over the console ...

[sourcecode language="Ruby"] def ilmerge(output\_name, assemblies)
ilmerge = get\_tool :ILMerge expanded\_assemblies = assemblies.map do
|x| x.expand\_to(:build\_dir).escape end sh "\#{ilmerge.escape}
/out:\#{output\_name.expand\_to(:deploy\_dir).escape}
\#{expanded\_assemblies.join(" ")}" end [/sourcecode]

Currently 3 assemblies pop out of the Rake build. These are xunit.dll,
xunit.bddextensions.dll and Rhino.Mocks.dll. While it's technically no
problem to merge them into a single assembly (and of course I would love
to have it that way) there are two problems currently not solved. The
R\# runner dynamically loads the xunit.dll to run the tests and
StructureMap.AutoMocking.dll dynamically loads Rhino.Mocks.dll. That's
the reason why I'm currently not able to merge it.

Any suggestions how to solve that?
