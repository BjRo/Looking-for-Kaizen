---
author: BjRo
date: '2009-08-28 15:38:24'
layout: post
slug: implementing-the-notification-pattern-using-dataannotation-validators
status: publish
title: Implementing the Notification Pattern using DataAnnotation Validators
wordpress_id: '509'
? ''
: - WPF
  - WPF
  - WPF
  - WPF
---

Some weeks ago a friend of mine told me about
System.ComponentModel.DataAnnotations. It's a relatively new addition to
the framework, mainly Asp.net related (mh, was it Mvc or Asp.net Dynamic
Data? I'm sure he told me, but I can't remember). Although I'm more
focussed on client side development (WinForms + WPF), what he told me
made me curious enough to spend some time with it in order to
investigate whether the DataAnnotation framework could be reused for
validation in a desktop app. **Background** What I was particulary
interested in was whether I could use it in order to implement some sort
of declarative validation (for most of the standard cases) on my WPF
ViewModels. The usage I wanted to achieve was something similar to the
code shown in the next listing. [sourcecode language="csharp"] public
class CustomerViewModel { private IValidator \_validator; private
NotificationCollection \_notifications; [Required] [MinLenght(3)]
[DisplayName("First name")] public string FirstName { get; set; }
[Required] [MinLenght(3)] [DisplayName("Last name")] public string
LastName { get; set; } [Required(ErrorMessage="The field Email address
is mandatory")] [ValidEmail] [DisplayName("Email address")] public
string EmailAddress { get; set; } public CustomerViewModel(IValidator
validator) { \_validator = validator; \_notifications = new
NotificationCollection(); } public NotificationCollection Notifications
{ get { return \_notifications;}} public bool IsValid() {
\_notifications.Clear(); \_validator.Validate(this, \_notifications);
return \_notifications.ContainsErrors; } } [/sourcecode] **Here is what
I came up with in order to use the DataAnnotation Validators for this**
First of all, some basics. I'm going to demonstrate a (very simple)
implementation of the Notification pattern in this post. A detailed
explanation this pattern is a bit out of scope for this post, but
here're some excellent resources for that:

-   [The Notification
    Pattern](http://martinfowler.com/eaaDev/Notification.html) by Martin
    Fowler
-   [Domain centric validation with the Notification
    Pattern](http://codebetter.com/blogs/jeremy.miller/archive/2007/06/13/build-your-own-cab-part-9-domain-centric-validation-with-the-notification-pattern.aspx)
    by Jeremy D. Miller

We're starting with a base class for our Notifications. It's a simple
abstract class containing a message and a Source property. Besides that
it contains an implicit conversion to string. [sourcecode
language="csharp"] public abstract class Notification { private readonly
string \_message; protected Notification() : this(string.Empty,
string.Empty) { } protected Notification(string message) :
this(string.Empty, message) { \_message = message; } protected
Notification(string source, string message) {
Require.ArgumentNotNull(source, "source");
Require.ArgumentNotNull(message, "message"); \_message = message; Source
= source; } public string Source { get; protected set; } public override
string ToString() { return \_message; } public static implicit operator
string(Notification notification) { return notification.ToString(); } }
[/sourcecode] Error is a simple class derived from Notification, which
contains no additional code. [sourcecode language="csharp"] public class
Error : Notification { public Error(string source, string message) :
base(source, message) { } public Error(string message) : base(message) {
} } [/sourcecode] I've seen some people implementing the Notification
pattern with a single Notification class and an enumeration specifying
the type of the Notification (Error, Warning, Info, etc.) but I prever
using classes for this. I think readability is way better (and shorter)
using classes. Decide for yourself: [sourcecode language="csharp"] bool
isError = notification is Error; //versus bool isError =
notification.Severity == Severity.Error; [/sourcecode] It's very rare
that you only have to validate one element / property. Mostly we're
dealing with more than one elment beeing validated. Because of that it's
useful to have a container or collection for Notifications. This gives
you a nice place for some additional functionality. [sourcecode
language="csharp"] public class NotificationCollection :
ObservableCollection { public bool ContainsErrors { get { return
this.Exists(notification =\> notification.IsOfType()); } } public bool
ContainsWarnings { get { return this.Exists(notification =\>
notification.IsOfType()); } } public IEnumerable
AllNotificationsFor(string nameOfSource) { return
this.Where(notification =\> string.Equals(notification.Source,
nameOfSource, StringComparison.Ordinal)); } } [/sourcecode] While the
first properties are pretty obvious, the last method probably needs some
explanation. It finds all notifications for a given source name. The
source in my implementation is the name of the property on the ViewModel
that was validated. Im currently using a little convention here.
Properties in WPF views have the same name as the ViewModel properties
they're bound to. This makes it relatively easy to correlate those two
things (meaning deciding which Notification belongs to which UIElement).
Having set this up, let me walk you through the validator
implementation. **A Validator<T\> using DataAnnotations** [sourcecode
language="csharp"] public class Validator : IValidator { private static
readonly IEnumerable Validators; static Validator() { var properties =
typeof (TElement).GetProperties(BindingFlags.Instance |
BindingFlags.Public); Validators = from property in properties where
property.IsMarkedWith() select new PropertyValidator(property); }
[/sourcecode] The static constructor of the Validator class uses
reflection to find all marked properties of the target type specified
via the generic type argument TElement. It searches for properties
marked at least with one derivate of the
System.ComponentModel.DataAnnotations.ValidationAttribute and creates a
PropertyValidator for each match. [sourcecode language="csharp"]
\#region IValidator Members public void Validate(TElement element,
NotificationCollection notifications) { Validators.Each(entry =\>
entry.Validate(element, notifications)); } \#endregion [/sourcecode] The
actual validation happens inside the Validate method. This method simply
uses all known PropertyValidators in order to validate the target
object. [sourcecode language="csharp"] \#region Nested type:
PropertyValidator private class PropertyValidator : IValidator { private
readonly PropertyInfo \_property; private readonly string
\_propertyDisplayName; private readonly IEnumerable
\_propertyValidators; public PropertyValidator(PropertyInfo property) {
\_property = property; \_propertyDisplayName =
GetDisplayName(\_property); \_propertyValidators =
GetValidators(property); } [/sourcecode] A PropertyValidator does some
things internally when it's created. First it determines the name for
the validated element which should be used in the UI. Since you probably
don't want the user to see something like "FirstName is required" or
"SelectedCountry is required" I'm using
System.ComponentModel.Design.DisplayNameAttribute here which can be used
to specify a UI-friendly name. If no DisplayNameAttribute is specified
on a property the validator uses the property name instead. [sourcecode
language="csharp"] private static string GetDisplayName(PropertyInfo
property) { if (property.IsMarkedWith()) { return
property.GetAttribute().DisplayName; } return property.Name; }
[/sourcecode] After it has determined the UI friendly display name it
extracts all DataAnnotations ValidationAttributes from the property.
(Note: GetAttributes is an ExtensionMethod. Same applies to IsMarkedWith
and GetAttribute) [sourcecode language="csharp"] private static
IEnumerable GetValidators(PropertyInfo property) { return
property.GetAttributes(); } [/sourcecode] And here is the rest, which
brings the whole thing to life. This code simply extracts the value from
the property, iterates over all known ValidationAttributes and checks
the value with them. When a ValidationAttribute signals that a value is
not valid, an error message is formatted with the UI-friendly name I
talked earlier about and the whole thing is stored as an Error.
[sourcecode language="csharp"] \#region IValidator Members public void
Validate(TElement element, NotificationCollection notifications) { var
value = \_property.GetValue(element, new object[] {});
\_propertyValidators.Each(validator =\> { if (!validator.IsValid(value))
{ string formmattedErrorMessage =
validator.FormatErrorMessage(\_propertyDisplayName);
notifications.Add(new Error(\_property.Name, formmattedErrorMessage)); }
}); } \#endregion [/sourcecode] **Bottom line** It's pretty easy to
combine the existing functionality provided by DataAnnotations with the
Notification Pattern. It just took me an hour to get to a working
solution which I consider pretty fast and which imho indicates an easy
to use framework. As you can imagine the hard part isn't getting the
Notifications out of the model, but rather finding an unrepetative,
intuitive way to display them in the UI. In the past I've missed several
times the pit of success regarding this aspect. However I'm really
confident that my current solution is really Dry AND easy to use. In one
of the next posts I'm going to show how to combine Attached Behavior,
Styles and Templates in order to bring the Notifications described in
this post to the applications front door, the UI . . .
