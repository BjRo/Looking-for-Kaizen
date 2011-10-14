---
author: BjRo
date: '2009-07-08 23:19:01'
layout: post
slug: thats-why-i-like-open-source
status: publish
title: That’s why I like Open Source . . .
wordpress_id: '384'
? ''
: - xUnit.BDDExtensions
  - xUnit.BDDExtensions
  - xUnit.BDDExtensions
  - xUnit.BDDExtensions
---

Today I received a really nice feature for xUnit.BDDExtensions from a
former colleague and friend of mine. It came to me completely with a
spec demonstrating and documenting its usage. Completely awesome. I wish
day to day software development would always be like that.

The feature deals with chained properties on interfaces. Consider the
following example: A presenter working against a composed passive view.
[code language="csharp"] public interface IComplexView { ISubView Header
{get;set;} } public interface ISubView { string Description {get;set;} }
public class Presenter { private IComposedView \_view; public
Presenter(IComposedView view) { \_view = view; } public void
Initialize() { \_view.Header.Description = "Some caption . . ." } }
[/code] A spec documenting the behavior of the presenter can now look
like this if you're using xUnit.BDDExtensions. [code language="csharp"]
[Concern(typeof(Presenter))] public class
When\_the\_presenter\_is\_initialized : InstanceContextSpecification {
protected override EstablishContext() { The().HasProperties(); }
protected override void Because() { Sut.Initialize(); } [Observation]
public void It\_should\_set\_the\_headers\_caption() {
The().Header.Description.ShouldBeEqualTo("Some caption . . . "); } }
[/code] A really large portion of the necessary glue code has been
removed for that scenario. Only the HasProperties() extension method
remains.

Great work, Sergey. I really like the implementation of that feature . .
.
