---
author: admin
date: '2010-03-15 21:28:45'
layout: post
slug: cutting-the-fluff-from-service-registration-with-structuremap-revisited
status: publish
title: Cutting the fluff from Service registration with StructureMap - revisited
wordpress_id: '781'
comments: true
categories: [dotnet, StructureMap]
---

This is just a quick update of an [older post of mine](/2009/07/24/cutting-the-fluff-from-service-registration-or-how-to-do-funky-stuff-with-coc-castledynamicproxy-structuremap/). 
Since StructureMap's convention API has [changed quite a bit](/2010/01/05/changes-in-structuremap-254/), 
here is the updated version of the code used in the post using the new APIs introduced in StructureMap 2.5.4.
<!--more-->

The new code is actually easier. It should look something like this . . . . 

``` csharp Singleton registration convention

    public class ServicesAreSingletonsAndProxies : IRegistrationConvention
    {
        #region IRegistrationConvention Members

        public void Process(Type type, Registry registry)
        {
            if (!type.IsConcrete() || !IsService(type) || !Constructor.HasConstructors(type))
            {
                return;
            }

            Type pluginType = FindPluginType(type);

            if (pluginType == null)
            {
                return;
            }

            registry
                .For(pluginType)
                .Singleton()
                .Use(new ConfiguredInstance(type)
                {
                  Interceptor = new DynamicProxyInterceptor(pluginType)
                });
        }

        #endregion

        private static bool IsService(Type type)
        {
            return type.Name.EndsWith("Service");
        }

        private static Type FindPluginType(Type concreteType)
        {
            string interfaceName = "I" + concreteType.Name;

            return concreteType
                .GetInterfaces()
                .Where(t => string.Equals(t.Name, interfaceName, StringComparison.Ordinal))
                .FirstOrDefault();
        }
    }

```
