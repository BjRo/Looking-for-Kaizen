---
author: BjRo
date: '2008-11-10 17:56:13'
layout: post
slug: glue-code-for-validation
status: publish
title: Glue code for validation
wordpress_id: '169'
comments: true
footer: true
categories: [dotnet]
---

Wouldn't it be nice to be able to just call 

``` csharp Validating a DTO
var report = myDto.Validate(); 
```

without sacrificing extensibillity, testabillity, etc? What about at this, 

``` csharp An extension method that calls into the IoC container
public static class ObjectExtensions 
{
	public static ValidationReport Validate(this Subject subject) 
	{ 
		return Container.GetInstance<IValidator<Subject>>().Validate(subject); 
	}
	public static ValidationReport Validate(this Subject subject, string validatorName) 
	{ 
		return Container.GetInstance<IValidator<Subject>>(validatorName).Validate(subject); 
	} 
}
```

where Container is just a simple static gateway for an IoC-container?
