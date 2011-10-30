---
author: BjRo
date: '2009-08-21 16:19:11'
layout: post
slug: diving-into-the-storyteller-trunk-part-8-the-screencollection
status: publish
title: 'Diving into the StoryTeller trunk, Part 8: The ScreenCollection'
wordpress_id: '502'
comments: true
footer: true
categories: [dotnet, StoryTeller]
---

Welcome back again to the "Diving into the StoryTeller trunk" series.
Got your diving suit on? If so, good. If not: Suit-up! (Sorry, the HIMYM
fanboy in me was too strong ;-))

Last time we spend some time with the concept of Screens. Screens more
or less provide the content of an application. Content needs to be
displayed somewhere and that's where the ScreenCollection concept comes
into play.

In abstract a ScreenCollection is a container for multiple Screens. It's
used to display screens. The ScreenCollection concept is comparable to
PRISMs Regions or CABs WorkSpaces. It doesn't really contain a lot of
intelligence. It only allows you to add a Screen, remove a Screen,
getting all Screens in the container, make a Screen the active one. You
know, all in all the typical stuff you would expect from a collection
(maybe except the last one). The ScreenCollection contract is
represented by the `IScreenCollection` interface which looks like this:

``` csharp The IScreenCollection interface
public interface IScreenCollection
{
      void ClearAll();
      IScreen Active { get; }
      void Show(IScreen screen);
      void Add(IScreen screen);
      void Remove(IScreen screen);
      IEnumerable<IScreen> AllScreens { get; }
      void RenameTab(IScreen screen, string name);
 }
```

If take a closer look at the interface you've probably recognized the last
method which doesn't really fit in there. Let's spare that discussion
for a moment. I'm going to comment on that in a moment.

StoryTeller contains only one implementation for the `IScreenCollection`
interface, which is called (what-a-surprise) `ScreenCollection`. This
class simply wraps around a standard WPF `TabControl`. Let's take a look
at how this is implemented, starting with the constructor. 

``` csharp StoryTellers ScreenCollection class
public class ScreenCollection : IScreenCollection
{
   private readonly Cache<IScreen, StoryTellerTabItem> _tabItems = new Cache<IScreen, StoryTellerTabItem>();
   private readonly TabControl _tabs;

   public ScreenCollection(TabControl tabs, IEventAggregator events)
   {
       _tabs = tabs;
       _tabItems.OnMissing = screen => new StoryTellerTabItem(screen, events);
       _tabs.SelectionChanged += (s, c) => { events.SendMessage<UserScreenActivation>(); };

       // Hack.  Sigh.
       events.AddListener(new RenameTestHandler(new ScreenFinder(this), this));
   }

  ...
}
```

There're are two interesting things to notice here. The `ScreenCollection` uses a cache concept in order to correlate
Screens and the TabItems used to display them. The `Cache<TKey,TValue>`
class is a smart wrapper around an `IDictionary<TKey,TValue>` which
(besides some other functionality) allows you to plug-in a custom
handler which is called when no value is found for the specified key.
This handler acts as a kind of value factory. That's exactly what we see
when we take a look at the line with `_tabItems.OnMissing`. Each time a
Screen is not found in the cache StoryTeller creates a new `StoryTellerTabItem`.

The other interesting thing to notice is that the `ScreenCollection`
doesn't directly expose events but rather uses the `Eventbroker` for this.
You can see this at the `UserScreenActivation` message.

Yeah and then there is the "RenameTab" thing. It's marked as a hack. It
simply shouldn't be there. The problem it currently solves it that when
a test is renamed the related `TabHeader` must also be updated (We take a
look at the `TabItem` in a moment). I wonder whether this isn't something
that could be done in a cleaner way using WPF databinding on `Screen.Title` instead.

Lets take a look at how the cache magic is used. It's really compact
code. Most of the methods are one or two liners. 

``` csharp Methods of the ScreenCollection class
public void ClearAll()
{
    _tabs.Items.Clear();
}

public void Show(IScreen screen)
{
    _tabs.SelectedItem = _tabItems[screen];
}

public void Add(IScreen screen)
{
    _tabs.Items.Add(_tabItems[screen]);
}

public void Remove(IScreen screen)
{
    TabItem tabItem = _tabItems[screen];
    _tabItems.Remove(screen);
    _tabs.Items.Remove(tabItem);
}

public IEnumerable<IScreen> AllScreens { get { return new List<IScreen>(_tabItems.Keys()); } }
```

The cache class is used like you would use a good old
Hashtable. All in all I think I don't need to say more here. Here is the
code for determining the active Screen. 

``` csharp Determining the active Screen
public IScreen Active
{
    get
    {
        if (_tabs.SelectedItem != null) return toScreen(_tabs.SelectedItem);

        return null;
    }
}

private IScreen toScreen(object tab)
{
    return tab.As<TabItem>().Tag.As<IScreen>();
}
```

Last but not least here's the code for the `TabItem` which is build around a
screen. 

``` csharp The StoryTellerTabItem class
public class StoryTellerTabItem : TabItem
{
    private Label _label;

    public StoryTellerTabItem(IScreen screen, IEventAggregator events)
    {
        Func<Action<IScreenConductor>, Action> sendMessage = a => () => events.SendMessage(a);

        Header = new StackPanel().Horizontal()
            .AddText(screen.Title, x => _label = x)
            .IconButton(Icon.Close, sendMessage(s => s.Close(screen)), b => b.SmallerImages());

        Content = new DockPanel().With(screen.View);
        Tag = screen;

        ContextMenu = new ContextMenu().Configure(o =>
        {
            o.AddItem("Close", sendMessage(s => s.Close(screen)));
            o.AddItem("Close All But This", sendMessage(s => s.CloseAllBut(screen)));
            o.AddItem("Close All", sendMessage(s => s.CloseAll()));
        });
    }

    public string HeaderText { get { return _label.Content as string; } set { _label.Content = value; } }
}
```

I need to talk more about this part, don't I? Again two
intersting things here. First thing, it really makes heavy usage of
C#3.0. You can see a lot of Extension Methods on WPF classes used in
order to build and configure WPF elements in a very fluent and compact
way.

Besides that you see here again how the `EventBroker` can be nicely
integrated into Screen handling. Take a look at the context menu of each
`TabItem`. It provides handlers which call directly into the `EventBroker`
for triggering the typical close operations you can also see in Visual
Studio. The important thing here to take away is that the close
operations are only triggered here but performed by the
`IScreenConductor`.

For those of you who didn't follow my "StoryTeller" investigations from
the start: The `ScreenConductor` is the great coordinator for the Screen
Activation Lifecycle behind the scenes. It's (as far as I can tell) the
central facade to the Screen Activation Lifecyle from the perspective of
typical application code. The `ScreenConductor` is a big topic which will
be discussed in one of the next posts.

Closing thoughts
------------------

Lets not comment on the `RenameTab` thing, ok? I bet, Jeremy is going to
fix that pretty soon. The `ScreenCollection` is (again) a good example of
how much you can do with so few lines. However sometimes this can have
downsides, too. I can only imagine .NET developers unfamiliar with this
heavy usage of C#3.0 features staring at the code and thinking
something like: WTF, what's happening here? Personally, I like it,
especially the cache aspect of it. I've done the .Tag thing far too
often now.

Sadly one thing I would have loved to see is missing in the code, the
ability to block deactivation or activation. Typical example for this is
a requirement forcing the user to save or discard changed data before
leaving a Screen. I had this requirement in the last 5 applications I
worked on. It would have been interesting to see how Jeremy tackles such
a requirement. I'm just assuming that he would use the `EventBroker` for
that ...

Enought Screen Mania for today. I hope you've enjoyed the ride so far
and we'll rejoin next time when it's time to take a look at the big guy
in the game, the `ScreenConductor`.
