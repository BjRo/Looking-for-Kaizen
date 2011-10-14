---
author: BjRo
date: '2009-10-20 21:38:09'
layout: post
slug: notifications-the-wpf-way-i-guess-part-i
status: publish
title: Notifications the WPF way (I guess), Part I
wordpress_id: '556'
? ''
: - WPF
  - WPF
  - WPF
  - WPF
---

**Update 2.11.2009: I removed the DependencyObject and
DependencyProperty references from the ViewModel. The solution works
fine without them.**

This is the start of a small mini series about how I would currently
approach the 'Notification Pattern' in a WPF application, using the
default WPF practices and patterns. Think about it as a step by step
guide for using DataBinding, Control-Templates, Styles,
Resource-Inheritance, Converters and the Attached-Behavior-Pattern for
displaying Notifications in the WPF-UI. (I guess most of this is also
doable in Silverlight too, but I've never done anything with SL so I
can't say for sure). I've also prepared a little bit of sample code for
this topic which will be download-able soon. **First,Â some cautious
warnings** I'm by no means a WPF-expert. I'm still in the learning
phase. So,Â if there are more obvious or intuitive solutions to the
problem, or I'm plain wrong about this,Â feel free to comment. I'm sure
there is A LOT room for improvement. **What I've left out
intentionally** I tried to strip everything unnecessary for the scope of
the post from the code. This includes for instance IoC, Convention over
Configuration, Code-Contracts, Expression-based Databinding setup and
some base class or extension refactorings. Don't get me wrong, I
absolutely value those elements, but I wanted the example to be as easy
as possible while being somewhat useful for a 'real world' application.
The code might look a bit raw at at some edges because of this. So
please keep that in mind before throwing with stones ;-) **Some other
prerequesites** A while back I wrote a post about [implementing the
Notification-pattern using
System.Componentmodel.DataAnnotations](http://www.bjoernrochel.de/2009/08/28/implementing-the-notification-pattern-using-dataannotation-validators/).
It demonstrates the implementation of a generic validator based on the
DataAnnotation attributes. Besides that,
[this](http://www.bjoernrochel.de/2009/08/19/the-attached-behavior-pattern/)
post about the Attached-Behavior-Pattern will also be useful for this
mini-series. Please give them a short visit if you haven't read them
yet. **The example scenario** The scenario I'm going to use for the
example is a very simple sign up form. It contains two input fields for
username / email and a 'sign-up' button. It looks like this.
[![image](http://www.bjoernrochel.de/wp-content/uploads/2009/10/signup.bmp)](http://www.bjoernrochel.de/wp-content/uploads/2009/10/signup.bmp)
Rules associated with the fields are: 1. Username is required and must
at least be 5 characters long. 2. Email is required and must contain a
valid email address. If any of the rules is broken, the related element
should be visually highlighted . . .
[![image](http://www.bjoernrochel.de/wp-content/uploads/2009/10/signupadorner.bmp)](http://www.bjoernrochel.de/wp-content/uploads/2009/10/signupadorner.bmp)
. . . and when you hover over the element you'll get a detailed
description of the error from a tooltip.
[![image](http://www.bjoernrochel.de/wp-content/uploads/2009/10/signuptooltip.bmp)](http://www.bjoernrochel.de/wp-content/uploads/2009/10/signuptooltip.bmp)
I'm using the PresentationModel / MVVM pattern for the UI since it seems
to be the default UI pattern in WPF. **This is how I would like my
SignUpView to be** [sourcecode language="xml"] [/sourcecode] **This is
how I would like my SignUpViewModel to be** [sourcecode
language="csharp"] public class SignUpViewModel : INotificationSource {
private readonly NotificationCollection \_notifications; private
readonly DelegateCommand \_signUpCommand; private readonly
ISignUpService \_signUpService; private readonly IValidator \_validator;
\#region Constructors public SignUpViewModel(IValidator validator,
ISignUpService signUpService) { \_validator = validator; \_signUpService
= signUpService; \_notifications = new NotificationCollection();
\_signUpCommand = new DelegateCommand(TrySignUp); } \#endregion \#region
Properties [Required(ErrorMessage = "Field 'Username' is missing")]
[MinimumStringLength(5)] public string Username { get; set; }
[Required(ErrorMessage = "Field 'Email' is missing")]
[MinimumStringLength(5)] public string Email { get; set; } public
ICommand SignUpCommand { get { return \_signUpCommand; } } public
NotificationCollection Notifications { get { return \_notifications; } }
\#endregion \#region Private methods private void TrySignUp() { if
(!IsValid()) { return; } \_signUpService.TrySignUp(Username, Email); }
private bool IsValid() { Notifications.Clear();
\_validator.Validate(this, Notifications); return
Notifications.ContainsErrors; } \#endregion } [/sourcecode] **Did you
notice it?** There is NO CODE in the View (Xaml and code behind) or the
ViewModel which displays the Notifications.There's also no base class
for View or ViewModel where the code might be. What's there on the other
hand is only a collection of Notifications hanging of the ViewModel
which is filled by the Validator. You might yourself now ask: Where is
the damn glue code? Yeah I know dumb question because I answered it
mostly in the introduction of the post. The interesting thing is that it
isn't a single location. As you will see the responsibilities for
achieving the effect are separated between several components. **In the
next posts we're going to take a look at**

-   how to use the Attached-Behavior-Pattern together with Styles and
    resource based inheritance in order to match the Notification (s)
    from the ViewModel to the related FrameworkElements in the logical
    WPF tree.
-   how to use a DataTrigger on an Attached Properties in order to setup
    the Tooltip and showing the red border.
-   how to bind the Tooltip correctly to the related Notification (s).

I hope I made you at least a bit curious . . .
