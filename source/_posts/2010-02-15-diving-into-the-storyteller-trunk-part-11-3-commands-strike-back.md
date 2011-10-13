---
author: admin
date: '2010-02-15 20:21:20'
layout: post
slug: diving-into-the-storyteller-trunk-part-11-3-commands-strike-back
status: publish
title: 'Diving into the StoryTeller trunk, Part 11.3: Commands strike back'
comments: true
wordpress_id: '762'
categories: StoryTeller
footer: true
---
One of the things that can hit you really hard when writing blog posts about open source software (like StoryTeller is), 
is the fact that your posts tend to get very fast outdated, especially when you don't pay that much attention to the detail (like I did, sigh). 
If you're not aware of what I'm talking about, it's StoryTellers command story. I'm not sure when it changed but it definitely has changed and I 
needed to update my last post [11.2](/2010/01/09/diving-into-the-storyteller-trunk-part-11-2-more-on-commands/) quite a bit in order 
to reflect the changes. Today I would like to conclude my trip through StoryTellers UI infrastructure with a look at how Commands are integrated 
into the Screen Activation Lifecycle.  

Some of my older posts on the topic showed that the component responsible for Screen activation and deactivation in StoryTeller is the ScreenConductor. 
However, when the ScreenConductor activates or deactivates a Screen, it delegates a major part of work to the so called IShellService. 
The only implementer of this interface, the ShellService, is just a little facade around three things.

1. The ICommandbar, which is the main toolbar of StoryTeller,
2. the IOptionsMenu, which is a kind of Shortcut menu for StoryTellers Commands and
3. the IScreenObjectRegistry, which acts as a store  / front-end for the current Command registration.


``` csharp The ShellService
    public class ShellService : IShellService
    {
        private readonly ICommandBar _Commands;
        private readonly IOptionsMenu _options;
        private readonly IScreenObjectRegistry _registry;

        public ShellService(
              IScreenObjectRegistry registry, 
              ICommandBar Commands, 
              IOptionsMenu options)
        {
            _registry = registry;
            _Commands = Commands;
            _options = options;
        }

        #region IShellService Members

        public void ActivateScreen(IScreen screen)
        {
            _registry.ClearTransient();
            screen.Activate(_registry);
            refill();
        }

        public void ClearTransient()
        {
            _registry.ClearTransient();
            refill();
        }

        public void Start()
        {
            refill();
        }

        #endregion

        private void refill()
        {
            _Commands.Refill(_registry.Actions);
            _options.Refill(_registry.Actions);
        }
```

You can see some interesting aspects in the short code above.

1. The word transient appears several times. StoryTeller differentiates between two types of Commands: 
Permanent Commands and transient Commands. Permanent Commands are displayed, well permanently, while transient Commands are 
what I depicted as contextual Commands. They are Commands which should be only visible in a particular context. 
2. Contextualization of Commands is handled on a per Screen basis in StoryTeller. Every time a Screen gets activated or 
deactivated the ICommandBar and the IOptionsMenu get reset and completely rebuild. With this you can have a very different Command UI 
depending on which Screen is activated.
3. The actual Command configuration in the Screen Activation Lifecycle is completely delegated to the active Screen. In his Activate() method he 
receives a reference to the IScreenObjectRegistry which can be used in order to start the Command configuration via a small fluent API. 

``` csharp IScreenObjectRegistry 
    public interface IScreenObjectRegistry
    {
        //Gets a collection of all currently known command configurations  
        IEnumerable<ScreenAction> Actions { get; }
        
        //Removes all transient command configurations from the registry
        void ClearTransient();

        //DSL starting point for the configuration of transient Commands
        IActionExpression Action(string name);

        //DSL starting point for the configuration of permanent Commands
        IActionExpression PermanentAction(string name);
    }

```

The following code snippet shows an example of how this API could be leveraged inside a Screen.

``` csharp Inside a screen
        public void Activate(IScreenObjectRegistry screenObjects)
        {
            screenObjects
                .Action("Save")
                .Bind(ModifierKeys.Control, Key.S)
                 .To(_save); //This can be either Systen.Action or an System.Windows.Input.ICommand

            screenObjects
                .Action("Cancel")
                .Bind(Key.Escape)
                .To(_cancel);
        }

```

Gabriel Schenker has [written an excellent series on how to write such a fluent API](http://www.lostechies.com/blogs/gabrielschenker/archive/2010/01/08/fluent-silverlight-table-of-content.aspx). 
Although it's targeting Silverlight, most of the involved problems are explained in detail there, so forgive me if I don't dive into the actual DSL implementation.

Some final thoughts
---------------------

Making the Screen responsible for setting up his Commands makes a lot of sense to me, since the Screen is the unit which gets plugged into the UI infrastructure 
and it also very likely plays the role of the Command receiver in terms of the classic GoF pattern description. 
This doesn't necessary mean that Screens are the only place for Command configuration. 
The initialization of modules in a Composite application is also a very likely place for registration of permanent Commands.

I consider having a fluent API for configuring the Commands also a plus, because it IMHO makes the actual Command configuration a lot easier and accessible. 
I've used the same setup (fluent API + delegation to screen) on my last 3 projects and it always worked for me like a charm.

Like I mentioned in the previous post, what I don't like that much is the idea of mixing in visual aspects (Icon, Size, Location) into the Command configuration, 
mostly because I've been burned by this in the past when facing complex menus, like the ribbon. 
I think it's a good idea to externalize the visual aspect via XML, at least for all the static stuff.

This is it
-------------
This was the last post about StoryTeller (at least for a while). It has been an interesting voyage which taught me a lot about UI infrastructure design, 
StructureMap usage and Convention over Configuration. Although it was primarily my learning excercise I hope you took something interesting with you 
from this blog series, too.

I'm going to continue my research on UI architecture with another deep dive into [Rob Eisenbergs](http://devlicio.us/blogs/rob_eisenberg/default.aspx) [Caliburn](http://www.codeplex.com/caliburn) soon. 
If your interested I would be very happy to have you with me on that trip . . .
