---
author: BjRo
date: '2009-01-26 16:33:59'
layout: post
slug: automocking-in-xunitbddextensions
status: publish
title: AutoMocking in xUnit.BDDExtensions
wordpress_id: '248'
? ''
: - BDD
  - BDD
  - xUnit
  - xUnit
  - BDD
  - BDD
  - xUnit.BDDExtensions
  - xUnit.BDDExtensions
---

[sourcecode language="csharp"] public class
when\_an\_automatically\_resolved\_instance\_with\_a\_single\_dependency\_is\_used\_in\_a\_fixture
: InstanceContextSpecification { private object actualResult; private
IDependency dependency; private object expectedResult; protected
override void EstablishContext() { expectedResult = new object();
dependency = AutoDependency(); dependency.WhenToldTo(x =\>
x.Invoke()).Return(expectedResult); } protected override void Because()
{ actualResult = Sut.Invoke(); } [Observation] public void
should\_be\_able\_to\_verify\_calls\_made\_to\_the\_dependency() {
dependency.WasToldTo(x =\> x.Invoke()); } [Observation] public void
should\_execute\_the\_configured\_behavior\_on\_the\_dependency() {
actualResult.ShouldBeEqualTo(expectedResult); } } [/sourcecode]

This little feature was added to the trunk today. Yes, no CreateSut()
call. You can omit it for most of the simple scenarios. You can still
override it, if you need/have to. It uses the AutoMocking capabilities
of StructureMap internally.

I'm going to merge the different involved assemblies to a single
assembly soon in order to make deployment a bit easier . . .
