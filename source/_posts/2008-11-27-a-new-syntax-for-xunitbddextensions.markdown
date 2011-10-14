---
author: BjRo
date: '2008-11-27 15:21:51'
layout: post
slug: a-new-syntax-for-xunitbddextensions
status: publish
title: A new syntax for xUnit.BDDExtensions ???
wordpress_id: '195'
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

I've been doing BDD with the
"[context/specification](http://www.lostechies.com/blogs/colinjack/archive/2008/11/19/context-specification-available-frameworks-bdd.aspx)t"-
style for about 4 months now. Examples for this style are
[MSpec](http://codebetter.com/blogs/aaron.jensen/archive/2008/09/02/mspec-v0-2.aspx),
[NSpec](http://nspec.tigris.org/) or my little framework called
[xUnit.BDDExtensions](http://code.google.com/p/xunitbddextensions/).
What bothers me lately is that this style mixes context and behavior
under test into one fixture class name, which can be extremely long
because of that. An example to clarify what I mean: [sourcecode
language="csharp"] public class
When\_adding\_a\_contact\_to\_a\_user\_with\_no\_existing\_contacts { }
[/sourcecode] "Adding a contact" is the observed behavior in the context
of "no existing contacts". I believe this should be more obvious, which
made me thinking of how a syntax for this could look like. Having said
that, here is what I came up with. It's heavily inspired by MSpec and
[RBehave](http://dannorth.net/2007/06/introducing-rbehave). [sourcecode
language="csharp"] [SpecificationFor(typeof(PatientService))] public
class
A\_patient\_with\_a\_missing\_first\_name\_is\_not\_allowed\_to\_be\_persisted
{ Given a\_patient\_with\_a\_missing\_first\_name = () =\> { }; When
trying\_to\_save\_the\_patient = () =\> { }; It
should\_not\_persist\_the\_supplied\_patient = () =\> { }; It
should\_return\_a\_report\_indicating\_that\_the\_patients\_first\_name\_is\_required
= () =\> { }; } [/sourcecode] A generated report for this code might
look like this: \
\
 **Specifications for "PatientService"**

-   **A patient with a missing first name is not allowed to be
    persisted**
    -   **Given a patient transfer object with a missing first name**
    -   **when trying to save the patient**
        -   **it should not persist the supplied patient**
        -   **it should return a report indicating that the patients
            first name is required**

I'm still not 100% happy with this, because there is some sort of
duplication between the fixture name and the "givens" (at least in the
shown example), but with this approach you

1.  are able to separate context and behavior in a clean way,
2.  can describe the context very fine grained (by having multiple
    "givens")
3.  and besides that it looks cool ;-)

I would like to hear opinions on that. Is this something worth
implementing / adding to xUnit.BDDExtensions? Or am I off the track with
this?
