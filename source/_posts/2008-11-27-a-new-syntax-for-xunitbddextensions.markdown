---
author: BjRo
date: '2008-11-27 15:21:51'
layout: post
slug: a-new-syntax-for-xunitbddextensions
status: publish
title: A new syntax for xUnit.BDDExtensions ???
wordpress_id: '195'
categories: [Testing, dotnet, xUnitBDDExtensions]
footer: true
comments: true
---

I've been doing BDD with the "[context/specification](http://www.lostechies.com/blogs/colinjack/archive/2008/11/19/context-specification-available-frameworks-bdd.aspx)t"-
style for about 4 months now. Examples for this style are [MSpec](http://codebetter.com/blogs/aaron.jensen/archive/2008/09/02/mspec-v0-2.aspx),
[NSpec](http://nspec.tigris.org/) or my little framework called [xUnit.BDDExtensions](http://www.github.com/bjro/xunitbddextensions/).
What bothers me lately is that this style mixes context and behavior under test into one fixture class name, which can be extremely long
because of that. An example to clarify what I mean: 

``` csharp Context/Specification When/Then
public class When_adding_a_contact_to_a_user_with_no_existing_contacts { }
```

"Adding a contact" is the observed behavior in the context of "no existing contacts". I believe this should be more obvious, which
made me thinking of how a syntax for this could look like. Having said that, here is what I came up with. It's heavily inspired by MSpec and
[RBehave](http://dannorth.net/2007/06/introducing-rbehave). 

``` csharp Example for a new syntax
[SpecificationFor(typeof(PatientService))] 
public class A_patient_with_a_missing_first_name_is_not_allowed_to_be_persisted 
{
	Given a_patient_with_a_missing_first_name = () => { }; 
	When trying_to_save_the_patient = () => { }; 
	It should_not_persist_the_supplied_patient = () => { }; 
	It should_return_a_report_indicating_that_the_patients_first_name_is_required = () => { }; 
} 
```
A generated report for this code might look like this: 

Specifications for "PatientService"
--------------------------------------
-   A patient with a missing first name is not allowed to be persisted
    -   Given a patient transfer object with a missing first name
    -   when trying to save the patient
        -   it should not persist the supplied patient
        -   it should return a report indicating that the patients first name is required

I'm still not 100% happy with this, because there is some sort of duplication between the fixture name and the "givens" (at least in the
shown example), but with this approach you 

1.  are able to separate context and behavior in a clean way,
2.  can describe the context very fine grained (by having multiple
    "givens")
3.  and besides that it looks cool ;-)

I would like to hear opinions on that. Is this something worth implementing / adding to xUnit.BDDExtensions? Or am I off the track with this?
