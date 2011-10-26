---
author: BjRo
date: '2009-07-05 13:54:49'
layout: post
slug: dude-i-can-do-reports
status: publish
title: Dude, I can do reports
wordpress_id: '359'
comments: true
footer: true
categories: [dotnet, Testing, xUnitBDDExtension]
---

Over the past days I finally managed to spend some time with
xUnit.BDDExtensions. I can't possibly describe how good coming back to
xUnit.net feels after working with MSTest in my last project. The
speed, the extensibility model. It's simply not comparable. MSTest is
certainly a great tool in case you haven't worked with a unit test
framework before and it's integration into Visual Studio is definitely a
plus, too. However once you've got Resharper or Gallio installed the
integration aspect isn't really the big deal any more. Anyway, you can
find several changes in the current trunk ([(http://github.com/bjro/xunitbddextensions/)](http://github.com/bjro/xunitbddextensions/).

The biggest addition is the new ReportGenerator
-----------------------------------------------

I've wanted this for quite a while now but never really found the time
to implement it. After running the `RunBuild.cmd` in the "Build" folder
of the trunk you'll find the .exe in the `Deploy` folder. It's still a
bit raw but exactly what I need for my current client (yes, you heard
right. xUnit.BDDExtensions is currently being picked up at my current
client ;-))

Here are the current console arguments:

`/assembly` configures the spec assembly to extract a report from one or
more assemblies.

> ReportGenerator.exe /assembly:SomeSpecAssembly.dll 
> ReportGenerator.exe /assembly:C:\\Test\\SomeSpecAssembly.dll \
> ReportGenerator.exe /assembly:'C:\\Path with spaces\\SomeSpecAssembly.dll' 
> ReportGenerator.exe /assembly:SomeSpecAssembly.dll /assembly:SomeOtherSpecAssembly.dll

`/generator` configures the generator to use. There are currently two
generators implemented. One building an `ASCII` .txt file which looks like
[this]({{ root_url }}/images/posts/xunitbddextensionsreportingspecs.txt).
In order to use it you have to run the generator with

> ReportGenerator.exe /assembly:SomeSpecAssembly /generator:Text

The other creating an HTML file which looks like
[this]({{ root_url }/images/posts/xunitbddextensionsreportingspecs.html).
This is the default generator which is used when you omit the
`/generator`  argument.

The files created by the generator are created on a per assembly basis
and named like the assembly with the suffix `.html` or `.txt`. By default
they are created in the same directory the generator is run from.

You can change this by configuring a different folder via `/path`.

> ReportGenerator.exe /assembly:C:\\Test\\SomeSpecAssembly.dll /path:C:\\temp

The deployment has changed slightly
--------------------------------------
The build script now merges xUnit.BDDExtensions to a single assembly
(the external Rhino.Mocks assembly is not needed any more). Same applies
to the ReportGenerator which uses StructureMap and NVelocity
internally. 

Some small changes to the API
--------------------------------
-   `Dependency<TDependency>()` has been marked as obsolete in
    `InstanceContextSpecification<T>` and `StaticContextSpecification`.
-   `AutoDependency<TDependency>()` has been marked as obsolete in
    `InstanceContextSpecification<T>`.
-   `An<TDependency>()` and `Some<TDependency>()` have been added to
    both `InstanceCOntextSpecification<T>` and `StaticContextSpecification`.
-   `The<TDependency>()` has been added to `InstanceCOntextSpecification<T>`,

Its mostly naming which has been changed. Some discussions at my current
client made me realize that it's easier to describe the behavior of xUnit.BDDExtensions to
developers who haven't used the tool before with `An<ICar>()` in favor
of `Dependency<ICar>()` and `The<ICar>()` in favor of
`AutoDependency<ICar>()`.

`An<TDependency>()` returns a new dynamic stub object every time it's
called. `The<TDependency>()` behaves differently. BDDExtensions has
AutoMocking support built-in. Once you let the framework create your
test object you're able to access the automatically injected dynamic
stubs with this method. Last but not least `Some<TDependency>()`
provides the same behavior as `An<T>()`. It only returns a collection
of newly created stub objects.

I'm going to write a more detailed documentation of the current version
soon. So in case you're interested in the BDDExtensions, stay tuned . .
.
