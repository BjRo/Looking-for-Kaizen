---
author: BjRo
date: '2008-11-08 12:16:31'
layout: post
slug: some-thoughts-about-validation-logic
status: publish
title: Some thoughts about validation logic
wordpress_id: '161'
? ''
: - C# 3.0
  - C# 3.0
  - Uncategorized
  - Uncategorized
  - C# 3.0
  - C# 3.0
  - Validaton
  - Validaton
---

The design of validation in software is one of those strange topics you
can discuss endlessly about. Some of the major questions concerning
validation:

1.  In which Layer should validation logic reside? Is it part of the
    Domain Layer, part of the Presentation Layer, or is it somehow part
    of both?
2.  Who is responsible for validation? Should the subject of the
    validation have the responsibility to validate itself or is that
    responsibility worth to be separated from the subject?)
3.  How should validation results be transferred to the caller? By
    throwing an exception, or by returning a sequence of validation
    results?
4.  How should a validation results be represented? As plain strings, or
    with the notification pattern?

I would like to discuss my point of view regarding those questions. I
don't claim my conclusions to be best-practices or something like that.
They are just my latest thoughts on that topic. Going from top to
bottom, here is what I would currently respond to those questions: **In
which layer should validation logic reside?** I think it's easier to
answer this question with saying where it primarily should not be: In
the Presentation Layer. Validation contains business know how. Therefore
it should reside in some lower or inner layer in my opinion. Which layer
actually should contain the validation logic depends on the actual
design of your application. When following a data centric approach, I
think it's best to put the validation logic in the business layer which
consumes your Data Transfer Objects. As I said: I strongly believe that
validation logic is business know how. When using a more Domain Driven
Design approach things get a little more difficult. A good place for
validation logic definitely is the domain layer. However one hot topic
on the Alt.NET mailing list in the past months was whether domain
objects should be able to have an invalid state or not. This decision
has naturally very strong implications on validation. Why should you
have validation in the domain layer when every domain object is by its
nature in a valid state after its construction and can never be invalid?
So if it's not in the domain where is it then? I would propose to put it
on the surrounding / higher layer, the Service Layer. The Service Layer
very often uses Data Transfer Objects in order to communicate with
higher level callers. This is mostly done to protect your domain design
from invasive infrastructure related stuff, for instance things you need
to implement in order to support databinding or correct serialization.
The service layer as I see it is in that case responsible for converting
DTOs to domain objects and calling some lower level functionality with
them. This is a good place for integrating validation based on the
incoming DTOs and currently my favourite place for validation. Here is a
simple sequence diagram to give you an idea about the interactions that
would happen inside such a layer.
[![image](http://www.bjoernrochel.de/wp-content/uploads/2008/11/servicelayer-300x67.png)](http://www.bjoernrochel.de/wp-content/uploads/2008/11/servicelayer.png)
**Who is responsible for the validation?** You might (or might not) have
recognized it in the sequence diagram above: I'm not a fan of having
validation logic inside the actual validation subject. For simple static
validations (like not null, string length, format) it would be
sufficient to bake validation logic into the subject. When it comes to
more real world scenarios I believe it's a good idea to separate the
validation from the subject. Why? For instance because of dependency
management and Open Closed Principle. A simple example: You have a
business object which contains a German zip code. The range of possible
values for this is pretty high. This is something that probably would be
validated against some sort of catalogue. Should the business object
know or event care about the catalogue? I believe it should not. Besides
that having external validation enables you to have context related
validation on a subject (Maybe some Service Layer operations need more
mandatory information than others . . . ) The business entity doesn't
need to be altered to support this. Jeremy Miller once said that every
Client-App should have an IPresenter interface. In the same way I would
argue that every application dealing with the need to validate inputs
should contain an IValidator interface. **How to transfer validation
errors to the caller?** How do most of the .NET framework classes handle
validation? They throw strong typed exceptions on invalid input.
Expressing validation errors through exceptions therefore seems
consistent for me with the rest of the framework. This also implicates
that a method signature of a higher level caller (f.e. a Service Layer
method) is not polluted with validation specific stuff (because the
exception can bubble up), which I would also consider a good thing. An
IValidator interface resulting from this conclusion might look like
this: [sourcecode language="csharp"] public interface IValidator { void
Validate(Subject subject); } [/sourcecode] However, you might want to
return validation results (like warnings for instance) but leave the
decision whether to continue execution to the caller. In that case
[sourcecode language="csharp"] public interface IValidator { IEnumerable
Validate(Subject subject); } [/sourcecode] might also be a valid
alternative. **How should validation results be represented?** I would
prefer using the Notification Pattern for transferring validation
results rather than using plain strings for that Why?

1.  A validation result can be much more than a simple message. It could
    contain other helpful information like a globally unique error code
    for instance in addition to just the plain message.
2.  In some cases you might want to differentiate between different
    classes of validation information, for instance between warnings and
    errors.
3.  It introduces the different types of validation information as a
    real concept to your application. It's more explicit.
4.  It frees the validation logic from having to deal with the
    validation messages itself. The messages can be changed without
    affecting the actual validation logic.

The notification pattern is pretty trivial. It consists of a base class
for notifications [sourcecode language="csharp"] public abstract class
Notification { public string Message {get; protected set;} }
[/sourcecode] and one or more derivates of it, representing generic
errors or warnings. [sourcecode language="csharp"] public class Error :
Notification { public Error (string message) { Message = message; } }
[/sourcecode] If you combine that with some kind of pseudo enumerations
like this [sourcecode language="csharp"] public static class
CustomerErrors { public static readonly Error FirstNameIsMissing = new
Error("The first name is missing"); public static readonly Error
FirstNameIsMissing = new Error("The first name is missing"); public
static readonly Error LastNameIsMissing = new Error("The last name is
missing"); public static Error InvalidEmail(string emailAddress) {
return new Error( string.Format("The email '{0}' is invalid",
emailAddress)); } } [/sourcecode] you're able to get pretty expressive
with validation logic. **Whats missing? Yeah right, the actual
validation . . .** I've written a little fluent API which helps me in
writing concrete validators in a very declarative way. The whole thing
is probably worth a post on its own so I won't go into detail so much
here and save a general discussion of the implementation for the next
post. So just a sneak preview here :-). [sourcecode language="csharp"]
public class CustomerDtoValidator : Validator { public
CustomerDtoValidator() { this.If(x =\> x.FirstName.IsNullOrEmpty())
.AddNotification(CustomerErrors.FirstNameIsMissing) .If(x =\>
x.LastName.IsNullOrEmpty())
.AddNotification(CustomerErrors.LastNameIsMissing) .If(x =\>
x.EmailAddress.IsNullOrEmpty())
.AddNotification(CustomerErrors.EmailAddressIsMissing) .If(new
EmailAddressSpecification())
.AddNotification(CustomerErrors.EmailAddressIsInvalid); } }
[/sourcecode] Neat isn't it? What you see here is actually very simple.
The If-AddNotification statement consists of the specification pattern
(as a real specification instance or in a more functional inlined lamda
version) and a second part that returns a notification. This second part
is only executed when the specification part is satisfied. All together
they form a chain of actions which are executed on a supplied subject.
**Stuff not mentioned in this post** There are still a lot of things I
did not cover in this post. A very obvious one is the topic of how to
map the notifications received from such a validation to controls in the
presentation layer. Besides that a bit of AOP or MDSD Code Generation
would also help to streamline the integration of this concepts. I'll try
to come back to the topic of validation soon. I would be happy to hear
some sort of feedback on this. So, feel free to comment, bash,
whatsoever . . .
