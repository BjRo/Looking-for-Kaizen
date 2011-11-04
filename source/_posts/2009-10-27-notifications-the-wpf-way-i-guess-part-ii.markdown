---
author: admin
date: '2009-10-27 21:29:16'
layout: post
slug: notifications-the-wpf-way-i-guess-part-ii
status: publish
title: Notifications the WPF way (I guess), Part II
wordpress_id: '574'
comments: true
footer: true
categories: [dotnet, sw-design]
---

Back again to my take on the Notification pattern with WPF. Last time I
talked briefly about my motivation for this little series. This time we
dive more into the nuts and bolts of my example implementation.

How the ViewModel notifies the UI
--------------------------------------------------

I defined an interface called `INotificationSource` for this. This
interface defines only I member which exposes a `NotificationCollection`.
`NotificationCollection` is just a standard `ObservableCollection<Notification>` with some additional bits in it
(such as retrieving a collection of `Notifications` for a given source).
By deriving from `ObservableCollection` you get the `CollectionChangedEvent`
on the collection for free. 

``` csharp The interface that needs to be implemented by a ViewModel
public interface INotificationSource
{
    NotificationCollection Notifications {get;}
}
```

In my current app I've got a `Layer Supertype` for
ViewModels which implements this interface.

Glue code for transferring Notifications from the ViewModel into the logical tree
--------------------------------------------------

As I mentioned in the last post I'm using the `Attached Behavior Pattern`
for transferring Notifications from the ViewModel to the related
elements in the logical tree (When I say related I'm referring to the
`FrameworkElements` bound to my ViewModel via DataBinding). The class
responsible for the transfer is a `DependencyObject` derived class, called
`ValidationBehavior`. This class defines two attached
`DependencyProperties`, `IsEnabled` and `Notifications`. 

``` csharp Our attached validation behavior
 public class ValidationBehavior : DependencyObject
 {
     public static readonly DependencyProperty IsEnabledProperty;
     public static readonly DependencyProperty NotificationsProperty;

     static ValidationBehavior()
     {
         IsEnabledProperty =  DependencyProperty.RegisterAttached(
                                 "IsEnabled",
                                 typeof(bool),
                                 typeof(ValidationBehavior),
                                 new FrameworkPropertyMetadata(OnValidationBehaviorEnabled));

         NotificationsProperty = DependencyProperty.RegisterAttached(
                                 "Notifications",
                                 typeof(NotificationCollection),
                                 typeof(ValidationBehavior),
                                 new PropertyMetadata(null));
     }

     public static bool GetIsEnabled(DependencyObject host)
     {
         return (bool) host.GetValue(IsEnabledProperty);
     }

     public static void SetIsEnabled(DependencyObject host, bool isEnabled)
     {
         host.SetValue(IsEnabledProperty, isEnabled);
     }

     public static NotificationCollection GetNotifications(DependencyObject host)
     {
         return (NotificationCollection)host.GetValue(NotificationsProperty);
     }

     public static void SetNotifications(DependencyObject host, NotificationCollection notification)
     {
         host.SetValue(NotificationsProperty, notification);
     }
}
```

The attached DependencyProperty `IsEnabled` is used to attach our
behavior to the target element marked with the property. Notice the
`OnValidationBehaviorEnabled` handler which is called when the value of
the registered attached DependencyProperty has changed. The attached
DependencyProperty `Notifications` will later hold the collection of
Notifications extracted from the ViewModel by our attached behavior. By
having the `NotificationCollection` as an attached property you're able to
bind against it from XAML (as we'll see in the following post). If you
recall the last post about this topic, maybe you remember that I didn't
actually set the attached property `IsEnabled` in the ViewModels XAML
file. You could configure the behavior in the related XAML file but I
didn't want to do this for all my ViewModels. Because of this I decided
to use Styles for this. 

``` xml XAML styles to wire it up
<!-- The global application class -->
<Application x:Class="Notifications.App"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <Application.Resources>
        <ResourceDictionary Source="Resources/Theme.xaml" />
    </Application.Resources>
</Application>

<!-- My XAML file containing the resources -->
<ResourceDictionary
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:Fx="clr-namespace:Notifications.Fx">

    <Style TargetType="Control">
        <Setter Property="Fx:ValidationBehavior.IsEnabled" Value="true" />
    </Style>

    <Style TargetType="TextBox" BasedOn="{StaticResource {x:Type Control}}" />

</ResourceDictionary>
```

When the Style is applied the `IsEnabled` attached property
will be automatically set on all elements based on that style and this
brings us into the position to hook into the elements events and access
the elements data. The `OnValidationBehaviorEnabled` handler is actually
straight forward. 

``` csharp Attach to the target FrameworkElement
private static void OnValidationBehaviorEnabled(
    DependencyObject dependencyObject,
    DependencyPropertyChangedEventArgs args)
{
    var frameworkElement = (FrameworkElement)dependencyObject;

    // Get the DataContext from the element. Mostly this DataContext is not directly
    // set on the element but rather derived from the parents DataContext
    var notificationSource = frameworkElement.DataContext as INotificationSource;

    if (notificationSource == null)
    {
        return;
    }

    // Clear related Notifications of an element when the element
    // got the focus.
    frameworkElement.GotFocus += ClearNotificationOnFocus;

    // Hook into the CollectionChanged event of the NotificationCollection.
    // I'm using a closure here in order to capture the FrameworkElement.
    notificationSource.Notifications.CollectionChanged += (sender, collectionChangedArgs) =>
    {
        var notifications = GetNotifications(notificationSource, frameworkElement);

        SetNotification(
            frameworkElement,
            notifications);
    };
}
```

The anonymous event handler registered for the `CollectionChangedEvent` tries to get the
collection of Notifications for the `FrameworkElement`. 

``` csharp Extracting the notifications for a particular element
private static NotificationCollection GetNotifications(INotificationSource notificationSource, FrameworkElement frameworkElement)
{
    return notificationSource.Notifications.AllNotificationsFor(frameworkElement.Name);
}
```

As you can see this particular piece of code has a
little quirk right now. It relies on the convention / assumption that
the property on the `ViewModel` and the bound `FrameworkElement` share the
same name. It was the easiest thing to do. It would also be easy to
introduce another attached property for this in order to specify the
name of the related ViewModel property. However this wouldn't be 100%
DRY because you're most likely going to specify the property via the
Binding `MarkupExtension`, too. I'm open to suggestions of how this
correlation can be done better. The last missing code piece is the
handler which clears the Notification when it gets focus. It simply sets
the attached Notification property to null. 

``` csharp Resetting a notification on focus
private static void ClearNotificationOnFocus(object sender, RoutedEventArgs e)
{
    var elementWithNotification = (FrameworkElement)e.OriginalSource;
    elementWithNotification.SetValue(NotificationProperty, null);
}
```

Closing thoughts
--------------------------------------------------

I hope you're getting a feeling for what I wanted to show with this
little post series. Today I talked mostly about how `Notifications` can be
transfered from the `ViewModel` into the `WPF tree`. While the code
currently has some pieces in it that imho should be refactored
(correlation of the `Notifications`, `CollectionChangedEvent` currently
reloads all Notifications), I hope you saw in this post that it's
relatively easy to add such an ability to your app infrastructure
without a) having a base class constraint b) a lot of imperative code
and c) doing a lot of configuration. The next post will conclude this
little series mostly with `XAML` stuff. We're going to cover how to
combine the different tools (`DataTrigger`, `DataTemplates`,
`ControlTemplates`, `Converter`) that WPF offers in order to fire up a
Tooltip containing all Notifications for an element. 

CU next time . . .
