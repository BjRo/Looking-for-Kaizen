---
author: BjRo
date: '2009-08-19 08:46:01'
layout: post
slug: the-attached-behavior-pattern
status: publish
title: The Attached Behavior Pattern
wordpress_id: '493'
comments: true
footer: true
categories: [dotnet]
---

With new technologies often completely new patterns emerge as people try
to check-out how far a technology might take them. One interesting
example for this is the `Attached Behavior Pattern` which seems to get a
lot of attention in the WPF and Silverlight community lately. It's a
great example of what you can do with those technologies that was
previously only very hard to achieve (although sometimes in my calm
moments it feels a little bit like a hack to me).

Anyway, here is what the pattern actually does:

The `Attached Behavior Pattern` uses the moment when an attached
DependencyProperty is attached to a `DependencyObject` in order to wire
event handlers to it. With this you're able to extend the behavior of
elements in the WPF trees with arbitrary code.

Let's take a look at how this can be achieved. First of all we need a
class deriving from `DependencyObject` in order to be able to provide an
attached `DependencyProperty`. It uses the standard pattern of registering
the `IsEnabled` DependencyProperty in the static constructor (which is a
bit clunky, btw). 

``` csharp A behavior must derive from DependencyObject

public class MyBehavior : DependencyObject
{
    public static readonly DependencyProperty IsEnabledProperty;

    static MyBehavior ()
    {
        IsEnabledProperty = DependencyProperty.RegisterAttached(
            "IsEnabled", //Name of the property
            typeof(bool),//Type of the attached property
            typeof(MyBehavior),//Type of the class that provides the property
            new FrameworkPropertyMetadata(false)); //Default value
    }

    public bool IsEnabled
    {
        get { return this.GetValue<bool>(IsEnabledProperty); }
        set { SetValue(IsEnabledProperty, value); }
    }
}

```

Pretty standard stuff so far. However you can use another constructor of
`FrameworkPropertyMetdata` in order to supply a callback which is called
when the value of the attached property changes. 

``` csharp Registering for change notifications

IsEnabledProperty = DependencyProperty.RegisterAttached(
               "IsEnabled", //Name of the property
               typeof(bool),//Type of the attached property
               typeof(MyBehavior),//Type of the class that provides the property
               new FrameworkPropertyMetadata(false, OnBehaviorEnabled)); //Default value + Callback
```

Next thing we need to do is to configure this attached property on the `DependencyObject` we want to attach behavior to.
This is preferably done in XAML. You've got at least two options for
doing the configuration. The first option is to set your attached
property in the `XAML` file of a `UserControl`, `Page` or `Window` directly at
the source, the element you want to attach behavior to. 

``` xml Wiring it via XAML
<TextBox myNamespace:MyBehavior.IsEnabled="true" />
```

The other option is to use the the power of styles (an area were WPF really shines imho) in order to set it for
all elements to which a style is applied. 

``` xml Wiring it via XAML and styles
<Style TargetType="TextBox">
   <Setter Property="myNamespace:MyBehavior.IsEnabled" Value="true" />
</Style>
```

Personally I very much vote for the second option, because it enables you to specify the attached behavior in a single place in
contrast to configuring it at several places in your solution. Don't repeat yourself, unless you really need to.

Now, fasten your seatbelts. This is were the fun begins. When the WPF / Silverlight infrastructure loads the compiled baml from the resources
and builds the element tree from it (and with this attaches our new property to the specified elements) the callback method gets called.

``` csharp Attaching to the target instance
private static void OnBehaviorEnabled(
    DependencyObject dependencyObject,
    DependencyPropertyChangedEventArgs args)
{
    TextBox textBox = (TextBox)dependencyObject;

    textBox.LostFocus += (s,e) =>
    {
      //Put your little piece of magic here
    };

}

```

With first parameter of the callback you get a reference to the `DependencyObject` to which our attached property has been attached
to. You're now able to wire all sort of event handlers to the `DependencyObject` and are able to execute arbitrary code when the event
occurs.

Here ends our journey for today. Attached Behaviors is a really nice technique which enabled me to do something that I always wanted to have
in my WinForms apps but never found a satisfiing way to implement it (just a bit patience, I'm going to blog about it soon). I think it will
be interesting to see how this pattern is used in the future. While new patterns always have the tendency to be overused, I think that this
particular pattern can enable lots of valuable things . . .
