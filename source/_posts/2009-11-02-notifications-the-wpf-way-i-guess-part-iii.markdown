---
author: BjRo
date: '2009-11-02 19:59:00'
layout: post
slug: notifications-the-wpf-way-i-guess-part-iii
status: publish
title: Notifications the WPF way (I guess), Part III
wordpress_id: '584'
? ''
: - WPF
  - WPF
  - WPF
  - WPF
---

Today I would like to conclude my little series about the Notification
Pattern with (I guess at least for some of you) the most interesting
part: **Today is all about displaying Notifications in the UI**. This
post will guide you through all the steps I took in order to achieve the
affect I demonstrated in the [introduction
post](http://www.bjoernrochel.de/2009/10/20/notifications-the-wpf-way-i-guess-part-i/).
Last time I showed how I'm transfering Notifications from the ViewModel
into the logical WPF tree. If you've not read the previous posts, please
give them some minutes, because I'm not going to repeat a lot of them
today. You can find them
[here](http://www.bjoernrochel.de/2009/08/28/implementing-the-notification-pattern-using-dataannotation-validators/),
[here](http://www.bjoernrochel.de/2009/10/20/notifications-the-wpf-way-i-guess-part-i/)
and
[here](http://www.bjoernrochel.de/2009/10/27/notifications-the-wpf-way-i-guess-part-ii/).
As always, a quick reminder: *What I'm showing is in this series is
**how I've implemented the Notification Pattern**. I'm not claiming that
it's the only or the best way to do so. However, it's the one that works
very good for me.* **How to get the red border effect** The red border
has to be displayed when Notifications exists for a control. Technically
this means that the attached property "Notifications" (which is defined
on the ValidationBehavior class I showed in the last post) is set to a
non empty NotificationCollection. We can react to this by defining a
DataTrigger for this. In my own words I would describe DataTriggers as
*An in XAML defined event handler with a related criteria. When the
criteria is matched the DataTrigger gets executed. When it isn't matched
any more, the DataTrigger reverts the state of the element on which it's
defined to the state before it was executed.* Sounds usable for our
purpose. Think about it, we only want to show the red border, when the
attached property is set to a non empty collection. If the property is
reset the border needs to disappear. The only difficulty with
DataTriggers we need to solve on our way is how to configure that
exactly in XAML. DataTriggers can be easily set on primitives (such as
string, bool, etc.) or null, but there isn't an out of the box way for
setting our criteria in XAML. However you can use a custom Converter for
converting our value to a primitive "switch". [sourcecode
language="csharp"] [ValueConversion(typeof(NotificationCollection),
typeof(bool))] public class ContainsNotificationConverter :
IValueConverter { public object Convert(object value, Type targetType,
object parameter, CultureInfo culture) { return (value != null && value
is NotificationCollection && ((NotificationCollection)value).Any()); }
public object ConvertBack(object value, Type targetType, object
parameter, CultureInfo culture) { throw new NotSupportedException(); } }
[/sourcecode] Using this converter we can define our DataTrigger in the
Style for Controls like this: [sourcecode language="xml"]

[/sourcecode]

**How to display Notifications in a Tooltip**

Solving the Tooltip requirement was a bit more tricky (at least for me).
It took me quite some time to figure out how to do this in WPF. The
solution I'm going to show uses only XAML based code.

**1. Integrating the Tooltip into the DataTrigger**

We simply use our DataTrigger to automatically set theTooltip of a
Control in case Notifications exist. [sourcecode language="xml"]

[/sourcecode] Now the UI looks really crappy. The tooltip is not
recognizable as one. ![Horrible
Tooltip](http://www.bjoernrochel.de/wp-content/uploads/2009/11/signup_emptytooltip1.jpg)

**2. Using a ControlTemplate to style the Tooltip**

In order to shape the appearance of the Tooltip we can use Styles again.
You can change the whole visual appearance of a Control using Styles and
ControlTemplates. The template I defined consists mostly of a DockPanel
containing a Label (which provides the tooltips caption) and a TextBlock
(which will later contain the Notification messages). [sourcecode
language="xml"]

[/sourcecode] Our UI now looks like this. ![Tooltip with
ItemSource](http://www.bjoernrochel.de/wp-content/uploads/2009/11/signup_tooltipwithcontroltemplate1.jpg)
Not as crappy as before but we're not finished yet, because we're not
displaying Notifications yet.

**3. Define Databinding on the Tooltip**

Defining the Databinding was probably the hardest step I had to take.
The problem is that you need to get the NotificationCollection from the
Control the ToolTip is displayed on. Being not a WPF pro figuring out
how to do this took quite some time. Anyway, in order to get the
Notification there isn't much you need to do. The trick is to bind
against the property PlacementTarget on the ToolTip class itself. This
property holds the reference to the Control on which the Tooltip is
displayed. All we need to do is to add a Binding to the Style definition
that sets the DataContext of the ToolTip to the related control.
[sourcecode language="xml"]

[/sourcecode] The next step we need to take is setting up the Binding
for our attached property "Notifications". Because a
NotificationCollection can contain more than one Notification I used the
ItemsControl for displaying them in the content area of the ToolTip.
[sourcecode language="xml"]

[/sourcecode] Voila, our Notifications are finally displayed in the UI.
![Tooltip with
ControlTemplate](http://www.bjoernrochel.de/wp-content/uploads/2009/11/signup_tooltipwithcontroltemplate2.jpg)

**4. Styling the Notifications**

In my initial post I showed a hyphen in front of each Notification. This
is fairly easy to add, too. All you have to do is to define a
DataTemplate for the Notification class and set it as the ItemTemplate
of the ItemsControl we're using. [sourcecode language="xml"] -

[/sourcecode] DataTemplates are also the weapon of choice if you want to
display errors in a different fashion than warnings (for instance by
displaying a different icon). This is where we arrived. ![Tooltip
finished](http://www.bjoernrochel.de/wp-content/uploads/2009/11/signup_tooltipfinishedjpg.jpg)

**Closing thoughts**

What I like about the current solution is that it demonstrates in a nice
way how different the programming model of WPF actually is compared to
WinForms. The only imperative code we have is the code that transfers
Notifications from our ViewModel into the logical tree. That's it. The
rest, the complete visual appeal of the Notifications, is a separated
concern. Those two things can be changed independently from each other,
even by different roles in a development team (Designer/Developer).
Besides that I like the way the composition based WPF model helps my
application code to stay focused and clean with only minimum
implementation constraints on the ViewModel itself (the
INotificationSource interface). There're certainly things to improve
both in XAML and in the glue code but I consider it a good start to
build on. In case you're interested in the complete code, I've uploaded
it to a corner of the xUnit.BDDExtensions trunk. You can find it
[here](http://xunitbddextensions.googlecode.com/svn/trunk/Experiments/WPF/Notifications/).
Feel free to do whatever you want with the code . . .
