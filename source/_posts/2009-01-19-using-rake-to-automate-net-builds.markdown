---
author: BjRo
date: '2009-01-19 19:12:05'
layout: post
slug: using-rake-to-automate-net-builds
status: publish
title: Using Rake to automate .NET builds
wordpress_id: '208'
comments: true
footer: true
categories: [ruby]
---
Today I started writing my first build scripts in Ruby for a .NET project using Rake. 
This is what I came up with. 
``` ruby My fist rake script
require 'rake/clean' 

EXTERNALS_DIR = File.expand_path('../Externals') 
BUILD_DIR = File.expand_path('../Bin') 
SOURCE_DIR = File.expand_path('../Source')
CLEAN.include(FileList[File.join(BUILD_DIR, '*')]) 

desc "Compiles the gemini sources" 
task :build do 
	gemini_solution = File.join(SOURCE_DIR, 'Gemini.sln') 
	sh "msbuild /property:WarningLevel=4;OutDir=#{BUILD_DIR}/ #{gemini_solution}"
end 

desc "Runs all the tests on the gemini code" 
task :test do 
	assemblies = all_spec_assemblies() 
	xunit_console = File.join(EXTERNALS_DIR, "xUnit/xunit.console.exe") 
	assemblies.each do |assembly| 
		sh "#{xunit_console} #{assembly} /html #{assembly +'.UnitTests.html'}" 
	end 
end 

task :default => [:clean, :build, :test]

def all_spec_assemblies() 
	file_mask = File.join(BUILD_DIR, '*Specs.dll') 
	FileList[file_mask] 
end
```
I think this code demonstrates the qualities of Ruby as a scripting language and Rake as a build tool really well. 
It's very descriptive and even more important it doesn't have all the xml-slash-what-the-hell-is-going-on-here-noise
around it. I know it's a very simple solution, but I consider it a good start. Let's look a bit more detailed at the parts of the script.

``` ruby Defining paths 
EXTERNALS_DIR = File.expand_path('../Externals') 
BUILD_DIR = File.expand_path('../Bin') 
SOURCE_DIR = File.expand_path('../Source')
```
This part defines some directory constants that are used in the script. The rakefile is currently run from the directory 'Build'
which is on the same level as 'Externals', 'Bin' and 'Source'. Relative paths are expanded to absolute paths here. 

``` ruby Using the built-in clean task
CLEAN.include(FileList[File.join(BUILD_DIR, '*')]) 
```

This tiny little code piece modifies the built-in :clean task and adds all files under the BUILD_DIR to it. Running 'rake clean' on the console
will now delete all files from our build directory. 

``` ruby Invoking the sources
desc "Compiles the gemini sources" 
task :build do 
	gemini_solution = File.join(SOURCE_DIR, 'Gemini.sln') 
	sh "msbuild /property:WarningLevel=4;OutDir=#{BUILD_DIR}/ #{gemini_solution}"
end 
```

This is the first task I've actually written on my own. It's only a very small wrapper around msbuild that builds the
solution file. 

``` ruby running tests
desc "Runs all the tests on the gemini code" 
task :test do 
	assemblies = all_spec_assemblies()
	xunit_console = File.join(EXTERNALS_DIR, "xUnit/xunit.console.exe")
	assemblies.each do |assembly| 
		sh "#{xunit_console} #{assembly} /html #{assembly +'.UnitTests.html'}" 
	end 
end 

def all_spec_assemblies()
	file_mask = File.join(BUILD_DIR, '*Specs.dll') FileList[file_mask]
end 

```
That little code is a small wrapper around xUnit.net which invokes the xunit.console.exe for each file it finds in the build
directory that ends with 'Spec.dll'. These are the assemblies which contain the BDD-style tests in our project. 

``` ruby Defining the default task
task :default => [:clean, :build, :test] 
```
This last piece defines the :default build task. That's the task which is run when you don't specify a task directly when running rake from console. 
This will run all tasks in the order specified from left to right.

Conclusion
------------

The Rake build engine rocks !!! Its really simple and descriptive API is fun and Rake doesn't create a lot of ceremony around build scripts (Only
around 30 lines of code in my current script). However, you should be aware of one thing: Coming from a language with a lot of IDE support
(like C# in my case) to Ruby might not be as easy as it sounds. It took me quite a while to make the transition from Intellisense and Resharper
to using IRB and reading RDoc in order to explore new APIs . . .
