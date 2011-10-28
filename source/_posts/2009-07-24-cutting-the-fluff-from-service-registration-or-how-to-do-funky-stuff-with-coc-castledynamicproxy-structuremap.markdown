---
author: BjRo
date: '2009-07-24 18:46:07'
layout: post
slug: cutting-the-fluff-from-service-registration-or-how-to-do-funky-stuff-with-coc-castledynamicproxy-structuremap
status: publish
title: Cutting the fluff from Service registration (or how to do funky stuff with
  CoC, Castle.DynamicProxy & StructureMap)
wordpress_id: '458'
comments: true
footer: true
categories: [dotnet, StructureMap]
---
The more I play around with Convention over Configuration in combination
with StructureMap the more I'm amazed about what you can do with it and
how much it reduces the amount of code you need in order to configure
and wire stuff together. Today I implemented this convention for our
current prototype:

> Every class whose class name ends with 'Service' and who implements a
> service interface ( 'I' + ServiceName) is automatically registered as
> a Singleton and proxied

The reasoning behind this convention is that I'd like to remove a lot of
the common, redundant instrumentation code from Services in our
application. This includes for instance a lot of the logging, caching or
maybe argument validation aspects. It's currently implemented using
Castle.DynamicProxy2 although the actual service call interceptors
haven't been implemented so far. So let's walk through the code and see
what is necessary in order to realize this.

First of all you need to implement the `ITypeScanner` interface. Its basic
purpose is to inspect every type which has been picked up in the
scanning process of StructureMap and do container registration with it
in case the type meets the expected criteria. The interface looks like
this.

``` csharp StuctureMaps TypeScanner
public interface ITypeScanner 
{ 
  void Process(Type type, PluginGraph graph); 
} 
```

StructureMap contains a handy base class which contains a lot of helper
methods for implementing a convention, the `TypeRules` class. The basic
code for my convention looks like this: 

``` csharp My convention 

public class ServicesAreSingletonsAndProxies : TypeRules, ITypeScanner 
{ 
  #region ITypeScanner Members 
  
  public void Process(Type type, PluginGraph graph) 
  { 
    if (!IsConcrete(type) || !IsService(type) || !Constructor.HasConstructors(type)) 
    { 
      return; 
    } 
    
    var pluginType = FindPluginType(type); 
    
    if (pluginType == null)
    { 
      return;
    }
    
    var family = GetFamiliy(graph, pluginType); 
    var instance = CreateInstance(pluginType, type); 

    family.AddInstance(instance);
    family.SetScopeTo(InstanceScope.Singleton); 
  }
  
  #endregion 
} 
```

When my convention inspects a type, it first checks whether the type is
concrete, the type name ends with `Service` and whether the type has a
public constructor. If any of this criteria is not satisfied the type is
ignored. Then it tries to find the primary interface for the concrete
type. In case an interface has been found a bit StructureMap magic is
applied which configures the DynamicProxy integration and the plugin
family to be scoped as Singletons.

In order to integrate DynamicProxy the registration has to be done a bit
differently compared to how I've described it in previous posts. Instead
of using `PluginGraph.AddType()` I'm using
`PluginGraph.AddInstance(IInstance)`. This gives you some more options for
configuration, including adding `InstanceInterceptors` which are called
when an instance is resolved via StructureMap. That's the extension
point I've used. The configuration looks like this . . . 


``` csharp Configuring an interceptor
private static Instance CreateInstance(Type pluginType, Type concreteType) 
{ 
  return new ConfiguredInstance(concreteType) 
  { 
    Interceptor = new DynamicProxyInterceptor(pluginType) 
  };
} 
```

. . . and the code for the interceptor looks like this . . .

``` csharp An Castle.DynamicProxy interceptor
internal class DynamicProxyInterceptor : InstanceInterceptor 
{ 
  private static readonly ProxyGenerator ProxyGenerator = new ProxyGenerator(); 
  private readonly Type _pluginType; 
  
  public DynamicProxyInterceptor(Type pluginType) 
  {
    _pluginType = pluginType; 
  } 
  
  #region InstanceInterceptor Members 
  
  public object Process(object target, IContext context) 
  { 
    return ProxyGenerator.CreateInterfaceProxyWithTargetInterface( 
              _pluginType,
              target, 
              new LoggingInterceptor()); 
  } 
  
  #endregion 
} 
```

I'm using proxy creation over interfaces here. I prefer this over the
proxy over classes approach, because it doesn't force implementation
constraints like having to make every public method virtual or the need
to inherit from `MarshalByRef` onto the service classes.

That's basically it. The best of it: The whole rule can be easily tested
in a unit test. The following code uses xUnit.BDDExtensions for this.

``` csharp Testing the convention with xUnit.BDDExtensions
[Concern(typeof (ServicesAreSingletonsAndProxies))] 
public class When_applying_the__ServicesAreSingletonsAndProxies__convention : StaticContextSpecification 
{ 
  private Container _container; 

  protected override void Because() 
  { 
    _container = new Container(x => x.Scan(s =>
    { 
      s.AssemblyContainingType<IGuitarPlayerService>(); 
      s.With<ServicesAreSingletonsAndProxies>(); 
    }));
  } 
  
  [Observation] 
  public void Should_register_all_classes_ending_with__Service__which_also_have_a_contract_interface()
  {
    _container.GetInstance<IGuitarPlayerService>().ShouldNotBeNull(); 
  }
  
  [Observation] 
  public void Should_register_services_as_singletons_by_default() 
  {
    _container.GetInstance<IGuitarPlayerService>().ShouldBeEqualTo(_container.GetInstance()); 
  }

  [Observation] 
  public void Should_wrapp_a_service_in_a_dynamic_proxy_in_order_to_perform_AOPish_stuff()
  { 
    var instance = _container.GetInstance<IGuitarPlayerService>();
    instance.GetType().ShouldNotBeEqualTo(typeof(GuitarPlayerService)); 
  }
}

#region Test helpers 
public interface IGuitarPlayerService {} 

public class GuitarPlayerService : IGuitarPlayerService { } 
#endregion 
```
Here is the full code for this convention. Feel free to play with it / use it. That's all for today. 
 
Read you soon . . .

``` csharp The full convention
public class ServicesAreSingletonsAndProxies : TypeRules, ITypeScanner
{
    #region ITypeScanner Members

    public void Process(Type type, PluginGraph graph)
    {
        if (!IsConcrete(type) || !IsService(type) || !Constructor.HasConstructors(type))
        {
            return;
        }

        var pluginType = FindPluginType(type);

        if (pluginType == null)
        {
            return;
        }

        var family = GetFamiliy(graph, pluginType);
        var instance = CreateInstance(pluginType, type);

        family.AddInstance(instance);
        family.SetScopeTo(InstanceScope.Singleton);
    }

    #endregion

    private static Instance CreateInstance(Type pluginType, Type concreteType)
    {
        return new ConfiguredInstance(concreteType)
        {
            Interceptor = new DynamicProxyInterceptor(pluginType)
        };
    }

    private static PluginFamily GetFamiliy(PluginGraph graph, Type pluginType)
    {
        if (!graph.ContainsFamily(pluginType))
        {
            graph.CreateFamily(pluginType);
        }

        return graph.FindFamily(pluginType);
    }

    private static bool IsService(Type type)
    {
        return type.Name.EndsWith("Service");
    }

    private static Type FindPluginType(Type concreteType)
    {
        var interfaceName = "I" + concreteType.Name;

        return concreteType
            .GetInterfaces()
            .Where(t => string.Equals(t.Name, interfaceName, StringComparison.Ordinal))
            .FirstOrDefault();
    }

}

internal class DynamicProxyInterceptor : InstanceInterceptor
{
    private static readonly ProxyGenerator ProxyGenerator = new ProxyGenerator();
    private readonly Type _pluginType;

    public DynamicProxyInterceptor(Type pluginType)
    {
        _pluginType = pluginType;
    }

    #region InstanceInterceptor Members

    public object Process(object target, IContext context)
    {
        return ProxyGenerator.CreateInterfaceProxyWithTargetInterface(
            _pluginType,
            target,
            new LoggingInterceptor());
    }

    #endregion
}

[Concern(typeof (ServicesAreSingletonsAndProxies))]
public class When_applying_the__ServicesAreSingletonsAndProxies__convention_for_a_particular_interface : StaticContextSpecification
{
    private Container _container;

    protected override void Because()
    {
        _container = new Container(x => x.Scan(s =>
        {
            s.AssemblyContainingType<IGuitarPlayerService>();
            s.With<ServicesAreSingletonsAndProxies>();
        }));
    }

    [Observation]
    public void Should_register_all_classes_ending_with__Service__which_also_have_a_contract_interface()
    {
        _container.GetInstance<IGuitarPlayerService>().ShouldNotBeNull();
    }

    [Observation]
    public void Should_register_services_as_singletons_by_default()
    {
        _container.GetInstance<IGuitarPlayerService>().ShouldBeEqualTo(_container.GetInstance<IGuitarPlayerService>());
    }

    [Observation]
    public void Should_wrapp_a_service_in_a_dynamic_proxy_in_order_to_perform_AOPish_stuff()
    {
        var instance = _container.GetInstance<IGuitarPlayerService>();
        instance.GetType().ShouldNotBeEqualTo(typeof(GuitarPlayerService));
    }
}

#region Test helpers

public interface IGuitarPlayerService {}

public class GuitarPlayerService : IGuitarPlayerService { }

#endregion

```
