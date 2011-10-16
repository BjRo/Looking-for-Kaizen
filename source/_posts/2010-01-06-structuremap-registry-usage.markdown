---
author: BjRo
date: '2010-01-06 00:37:22'
layout: post
slug: structuremap-registry-usage
status: publish
title: 'StructureMap: Registry usage'
wordpress_id: '663'
comments: true
footer: true
categories: [dotnet, StructureMap]
---

I recently read something like this on Twitter: 

{% blockquote %}
It feels wrong to have registration and scanning in the Registry class
{% endblockquote %}

**I absolutely second that**. 
One of the decisions in my current project (a composite smart client) was to
separate these two things, in order to give clear guidance on "which to use when". 
Here is our setup: 

``` csharp Bootstrapping our container
ObjectFactory.Initialize(x => 
{ 
	x.AddRegistry(new InfrastructureRegistry()); 
	x.Scan(scanner => 
	{
			scanner.AssembliesFromPath("Modules"); 
			scanner.Convention<ProjectConventions>();
			scanner.LookForRegistries(); 
	});
}); 
```

- We packaged our conventions for the project into a single composite convention. This includes the easier mappings ala `IFoo` -- `Foo`, as
  well as more complex conventions for services which are automatically instrumented on creation via `Castle.DynamicProxy`.
- `Registry` classes are used for all the stuff we're not able to configure via conventions.  
	This includes mappings from interfaces to types with completely different names, adding externally created stuff to the container or configuring complex constructions like a composite.
- There is exactly 1 `Registry` per module in our application (+ 1 for the infrastructure).
- `Registry` classes are dynamically found during the scan process by looking into each assembly configured in the Scanner.

Any opinions? If you're using Registries, how do you use them?
