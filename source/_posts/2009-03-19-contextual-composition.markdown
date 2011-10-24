---
author: BjRo
date: '2009-03-19 23:00:22'
layout: post
slug: contextual-composition
status: publish
title: Contextual composition
wordpress_id: '297'
comments: true
footer: true
categories: [dotnet]
---

Today I would like to talk a little bit about something I've witnessed in software development over and over again. Actually, I've seen this
more or less in every commercial codebase I've worked with so far. I'm talking about giant switch statements, the misuse of inheritance and
code that is so entangled that it's a pain to work with it. And it just becomes harder and harder every day. Sounds familiar? I bet so. I'm
talking about the tiny little variations in behaviour of software and typical code that is written to handle them. Sounds abstract? Maybe a
little example might help. 

Example: A WorkItem viewer
-----------------------------
To be honest, I'm not really good at examples. I hope the following one is sufficient enough to transport what I'd like to show you. Let's say we're building
a software that displays WorkItems. WorkItems are in short a concept often used in ALM (Application Lifecycle Management) tools in order to
perform work and defect tracking. WorkItems can be assigned to a participating user. To add a little twist, let's say that there're two
roles in the application: Administrator and Developer. The Administrator is able to see all the items, while the Developer only sees the ones
assigned to him. This is how our little domain might look like:

[![WorkItem Domain Model]({{ root_url }}/images/posts/domain.bmp)]({{ root_url }}/images/posts/domain.bmp)

So let's have a look at how this might be implemented using Windows Forms, starting with the most common type. 

Type 1: The procedural one
-----------------------------
``` csharp A typical procedural implementation
public partial class WorkItemExplorer : Form 
{ 
	private readonly IWorkItemRepository workItemRepository; 

	public WorkItemExplorer() 
	{
		InitializeComponent(); 
	}
	
	public WorkItemExplorer(IWorkItemRepository workItemRepository) : this()
	{ 
		this.workItemRepository = workItemRepository; 
	} 

	protected override void OnLoad(EventArgs e) 
	{
		IList workItems; 
		
		if (Thread.CurrentPrincipal.IsInRole(ApplicationRoles.Admin)) 
		{ 
			workItems = workItemRepository.ToList(); 
		} 
		else
		{ 
			workItems = workItemRepository
									.Where(wi => Equals(wi.AssignedTo.Alias, Thread.CurrentPrincipal.Identity.Name))
									.Select(wi => wi)
									.ToList(); 
		}
		
		workItemList.DataSource = workItems; 
	} 
} 
```

This piece of code really raises strong emotions in me. Don't get me wrong I've written stuff like that myself, but I don't want to see code like this
anymore. What I especially don't like about it (besides the inability to be unit tested) is how easily it falls apart and becomes messy when new
roles with slightly different behaviour must be integrated later on.  

Type 2: The inheritance based one
-----------------------------------
If not procedural, let's do it the classic object oriented way. Isn't inheritance useful to solve our
problem? Why don't we use subclasses and polymorphism? This could get us something like this ...

[![image]({{ root_url }}/images/posts/inheritance.bmp)]({{ root_url }}/images/posts/inheritance.bmp)

... or if you prever code: 

``` csharp Using inheritance
public partial class AdminWorkItemExplorer : Form 
{ 
	private readonly IWorkItemRepository workItemRepository; 

	public AdminWorkItemExplorer() 
	{
		InitializeComponent(); 
	}
	
	public AdminWorkItemExplorer(IWorkItemRepository workItemRepository) : this() 
	{
		this.workItemRepository = workItemRepository; 
	} 
	
	protected override void OnLoad(EventArgs e) 
	{ 
		base.OnLoad(e); 
		workItemList.DataSource = LoadItems(workItemRepository); 
	} 
	
	protected virtual IList LoadItems(IWorkItemRepository workItemRepository) 
	{ 
		return workItemRepository.ToList(); 
	}
} 

public partial class DeveloperWorkItemExplorer : AdminWorkItemExplorer 
{ 
	public DeveloperWorkItemExplorer() 
	{ 
		InitializeComponent(); 
	} 
	
	public DeveloperWorkItemExplorer(IWorkItemRepository workItemRepository) : base(workItemRepository) { } 
	
	protected override IList LoadItems(IWorkItemRepository workItemRepository) 
	{ 
		return workItemRepository.Where(wi => Equals(wi.AssignedTo.Alias, Thread.CurrentPrincipal.Identity.Name)) 
						.Select(wi => wi)
						.ToList();
	}
}

public class WorkItemExplorerFactory 
{ 
	public static Form CreateExplorer() 
	{
		var wiRepository = new WorkItemRepository(); 
		
		if (Thread.CurrentPrincipal.IsInRole(ApplicationRoles.Admin)) 
		{ 
			return new AdminWorkItemExplorer(wiRepository); 
		} 
		
		return new DeveloperWorkItemExplorer(wiRepository); 
	} 
} 
```

Instead of one we've now got three classes: One Form for each role in addition to a little `Factory`. The `Factory` was added to encapsulate the creation of the concrete Form. The specialized behaviour is extracted into a virtual
method and overridden where it was needed. This is code I've seen less often in my career than the procedural one, but still I've seen it
often. This was the standard way for me personally to handle variation not so many years ago. When I originally started to write code for
object oriented systems, I almost all the time thought OO was about solving problems through inheritance. I can only guess, but I tend to
think that same applies to a lot of other developers out there. So what might be wrong with this design? First the obvious one: A
`DeveloperWorkItemExplorer` is a specialized `AdminWorkItemExplorer`. Aha, nice one! Inheritance is only used for technical reasons here. The
inheritance chain by itself doesn't really make sense on its own.  Besides that the `Extract & Override-Pattern` used here also tends to
degrade very fast. After time you'll often see more and more virtual methods appear in your class hierarchy as more variations are introduced
to your system. Another thing to mention is that you can only inherit once in .NET. The inheritance based solution becomes quickly messy when
you have to share code between different leaves of the inheritance tree, which are in no direct connection. 

Type 3: A glimpse at contextual composition
-------------------------------------------
Why don't we use composition to achieve what we need? Let's play a bit with generics and
try to build classes which can be composed together. Let's look at a possible implementation and its implications.

[![image]({{ root_url }}/images/posts/contextualcomposition.bmp)]({{ root_url }}/images/posts/contextualcomposition.bmp)

So whats different here (besides the amount of involved components :-))?

There is only one View. The complete behaviour is moved into a newly created `Presenter` class. 

``` csharp Refactoring to composition with a swappable Presenter
public partial class WorkItemExplorerView : Form, IWorkItemView 
{ 
	private readonly IPresenter presenter; 
	
	public WorkItemExplorerView() 
	{ 
		InitializeComponent(); 
	} 
	
	public WorkItemExplorerView(IPresenter presenter) : this() 
	{ 
		this.presenter = presenter; 
		this.presenter.View = this; 
	} 
	
	#region IWorkItemView Members public void RenderWorkItems(IList workItems) 
	{ 
		workItemList.DataSource = workItems; 
	} 
	#endregion
	
	protected override void OnLoad(EventArgs e) 
	{ 
		base.OnLoad(e);
		presenter.Load();
	} 
} 
```

There're two presenters, one for each role. 

``` csharp The Presenters
public class AdminWorkItemExplorerPresenter : Presenter 
{ 
	private readonly IWorkItemRepository repository; 
	
	public AdminWorkItemExplorerPresenter(IWorkItemRepository repository) 
	{
		this.repository = repository; 
	} 
	
	public override void Load() 
	{
			View.RenderWorkItems(repository.ToList()); 
	} 
} 

public class DeveloperWorkItemExplorerPresenter : Presenter 
{ 
	private readonly IWorkItemRepository repository; 
	
	public DeveloperWorkItemExplorerPresenter(IWorkItemRepository repository) 
	{
		this.repository = repository; 
	} 
	
	public override void Load() 
	{
		View.RenderWorkItems( repository 
			.Where(wi=> Equals(wi.AssignedTo.Alias, Thread.CurrentPrincipal.Identity.Name))
			.Select(wi => wi)
			.ToList()); 
	} 
} 
```

The Factory is composed out of reusable parts. 

``` csharp A generic composable factory
public interface IFactory<TSubject, TContext> 
{ 
	TSubject Create(TContext context); 
} 

public class InlineFactory<TSubject, TContext> : IFactory<TFactory, TContext>
{ 
	private readonly Func<TContext, TSubject> inlineFactory; 

	public InlineFactory(Func<TContext, TSubject> inlineFactory) 
	{ 
		this.inlineFactory = inlineFactory;
	} 
		
	#region IFactory<TContext, TSubject> Members 
	
	public TSubject Create(TContext context)
	{
		return inlineFactory(context); 
	}
		
	#endregion 
} 

public interface IContextualFactory<TSubject, TContext> : IFactory<TSubject, TContext> 
{ 
	bool CanHandle(TContext context); 
}

public class ContextualFactory<TSubject,TContext> : IContextualFactory<TSubject, TContext> 
{ 
	private readonly ISpecification<TContext> contextSpec; 
	private readonly IFactory<TSubject, TContext> factory;
	
	public ContextualFactory(
		ISpecification<TContext> contextSpec, 
		IFactory<TSubject, TContext> factory)
		{
			this.contextSpec = contextSpec; 
			this.factory = factory; 
		} 
		
	public ContextualFactory(
		Predicate<TContext> inlineSpec, 
		Func<TContext, TSubject> inlineFactory) : this( 
			new InlineSpecification(inlineSpec), 
			new InlineFactory(inlineFactory) ) { }

	#region IContextualFactory<TSubject, TContext> Members 
		
	public bool CanHandle(TContext context) 
	{ 
		return contextSpec.IsSatisfiedBy(context); 
	} 
		
	public TSubject Create(TContext context) 
	{ 
		return factory.Create(context); 
	} 
	
	#endregion
}

public interface ISpecification<TSubject> 
{ 
	bool IsSatisfiedBy(TSubject subject); 
} 

public class InlineSpecification : ISpecification<TSubject> 
{ 
	private readonly Predicate<TSubject> predicate; 
	
	public InlineSpecification(Predicate<TSubject> predicate) 
	{ 
		this.predicate = predicate; 
	} 
	
	public bool IsSatisfiedBy(Subject subject) 
	{ 
		return predicate(subject); 
	} 
} 

public class ComposedFactory<TSubject, TContext> : IFactory<TSubject, TContext> 
{ 
	private readonly List<IContextualFactory<TSubject, TContext>> factories;

	public ComposedFactory(params IContextualFactory<TSubject, TContext>[] factories) 
	{
		this.factories = new List><TSubject, TContext>(); 
		this.factories.AddRange(factories); 
	}

	#region IFactory Members 
	
	public TSubject Create(TContext context) 
	{
			return factories.First(factory => factory.CanHandle(context)).Create(context); 
	}
	
	#endregion 
} 

```

There is a composed factory consisting of special factories for each role. The composed factory chooses the inner factory based on its ability to handle the
context and delegates the creation to it. 

``` csharp Composing the factory
var composedFactory = new ComposedFactory<Form, IPrincipal>(
	new ContextualFactory<Form, IPrincipal>(
		context => context.IsInRole(ApplicationRoles.Admin), 
		create => new WorkItemExplorerView(new AdminWorkItemExplorerPresenter(new WorkItemRepository()))), 
	new ContextualFactory<Form, IPrincipal>( 
		context => context.IsInRole(ApplicationRoles.Developer), 
		create => new WorkItemExplorerView(new DeveloperWorkItemExplorerPresenter(new WorkItemRepository()))) ); 
```

This one was fun to write and I think it's a good step forward in comparison to the previous examples.
However I must admit that I'm not overwhelmed by the end result. One the one hand we can change a lot of the stuff easily without affecting other
code. The classes are small and are focused on their responsibilities.  We've managed to extract some code that is potentially reusable. On the
flipside it looks quite a bit over engineered, especially for this tiny little example. There is a lot of stuff we need to pull together in
order to make the solution work (although you could of course hide a lot of the details of the composition by wrapping it up in an internal
DSL.). 

Type 4: Contextual composition + IoC
--------------------------------------
Doesn't this look like a good situation to introduce an inversion of control container? Probably, but there's a tiny little problem. Most of the .NET IoC-Frameworks
unfortunately don't support dynamic contextual binding. This type of binding uses a context (for instance a parameter or something like the
current principle used in the current example) and determines how to resolve the target on-the-fly based on the context. This is more or less
the behaviour that I tried to implement manually in the previous example. To our luck there is one framework that implements such a
behaviour. This is Nate Koharis NInject. The reworked initialization of the code looks like this. 

``` csharp Configuring contextual composition with NInject
public class WorkItemExplorerModule : NinjectModule 
{ 
	public override void Load() 
	{
		Bind<IPresenter<IWorkItemExplorerView>>()
			.To<AdminWorkItemExplorerPresenter>()
			.When(x => Thread.CurrentPrincipal.IsInRole(ApplicationRoles.Admin)); 

		Bind<IPresenter<IWorkItemExplorerView>>()
			.To<DeveloperWorkItemExplorerPresenter>()
			.When(x => Thread.CurrentPrincipal.IsInRole(ApplicationRoles.Developer)); 

		Bind<IWorkItemRepository>().To<WorkItemRepository>();
	} 
} 
```

and it could be used like this 

``` csharp Configuring an running an app with NInject
var kernel = new StandardKernel(new WorkItemExplorerModule()); 
Application.Run(kernel.Get<WorkItemExplorerView>()); 
```

Do you see any unnecessary mechanics here? 

Bottomline 
--------------
With a little help of our little ninja friend we've managed to build a loosely coupled
system which is a) easy to change and b) easy to extend. NInject hides a lot of the needed mechanics behind the scenes and lets us focus on the
essence of the actual composition. While NInject certainly helps a lot, everything is still doable without such a container. That beeing said:
Favor composition over inheritance. Combine stuff in order to deal with variation. Leave nasty procedual and primarily inheritance bases
solutions behind. It will make your life a lot easier, at least it worked for me . . .
