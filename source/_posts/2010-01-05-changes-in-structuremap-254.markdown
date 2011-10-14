---
author: BjRo
date: '2010-01-05 23:45:14'
layout: post
slug: changes-in-structuremap-254
status: publish
title: Changes in StructureMap 2.5.4
wordpress_id: '658'
? ''
: - IoC
  - IoC
  - StructureMap
  - StructureMap
  - StructureMap
  - StructureMap
---

Interesting what some people do during the Christmas holidays. In the
case of Jeremy D. Miller this was releasing a new version of
StructureMap and working heavily on the Fubu MVC codebase. Today I had
the pleasure to migrate my current projects codebase (which previously
used Unity and Unity.Interception) to the newest StructureMap version
2.5.4 and Castle.DynamicProxy2. It was an interesting experience mostly
because I tried to re-use some code pieces for setting up conventions
from an earlier project based on StructureMap 2.5.3. Quite a few things
have been changed in the API. Needless to say, all for good. I just
wanted to give a quick overview of the things I noticed. **ITypeScanner
was replaced by IRegistrationConvention** If you wanted to write custom
conventions in StructureMap 2.5.3 you needed to implement the
ITypeScanner interface (An example is described
[here](http://www.bjoernrochel.de/2009/07/24/cutting-the-fluff-from-service-registration-or-how-to-do-funky-stuff-with-coc-castledynamicproxy-structuremap/)).
[sourcecode language="csharp"] //StructureMap 2.5.3 public interface
ITypeScanner { void Process(Type type, PluginGraph graph); }
//StructureMap 2.5.4 public interface IRegistrationConvention { void
Process(Type type, Registry registry); } [/sourcecode] As you can see,
it's not only a renaming. The signature of the Process-method has
changed, too. It now uses the good old Registry class for doing the
registration. Very consistent, good choice. Modifying the PluginGraph
always left me with the feeling that I was digging too deep into the
StuctureMap internals. **TypeRules base class has been replaced with
Extension methods** In the past you could re-use some utility methods
for reflection (like checking whether a type is concrete, etc.) by
inheriting from the TypeRules class. This class has been completely
removed, but the functionality is still available via Extension methods.
**Lot's and lot's of renaming** A lot of renaming has been done. The
most interesting stuff happened in the Registry class. [sourcecode
language="csharp"] //StructureMap 2.5.3 public class MyRegistry { public
MyRegistry() { ForRequestedType().TheDefaultIsConcreteType();
ForRequestedType().TheDefaultIsConcreteType().AsSingleton();
ForRequestedType().TheDefault.IsThis(new Foo)
ForRequestedType().TheDefault.Is.ConstructedBy(x =\> new Bar()); } }
//StructureMap 2.5.4 public class MyRegistry { public MyRegistry() {
For().Use(); ForSingleton().Use(); For().Use(new Foo) For().Use(x =\>
new Bar()); } } [/sourcecode] The new version is a lot less wordier and
a lot more consistent in naming. It also feels very familiar, although
I'm unable to determine why. **Some new slick features I noticed** From
playing around with the StructureMap trunk version during the "Diving
into the StoryTeller Series" I already stumbled over this killer
feature. [sourcecode language="csharp"] \_container = new Container(x
=\> x.Scan(s =\> { s.AssemblyContainingType();
s.ConnectImplementationsToTypesClosing(typeof(IHandler<\>)); }));
[/sourcecode] Jimmy Bogard has already written an [excellent
article](http://www.lostechies.com/blogs/jimmy_bogard/archive/2009/12/17/advanced-structuremap-connecting-implementations-to-open-generic-types.aspx)
about that particular feature. So instead let us take a look at this new
ability. [sourcecode language="csharp"]
ObjectFactory.Model.GetAllPossible(); [/sourcecode] This resolves all
instances from the configuration model which implement the
IInitializable interface. **Stuff you don't see** If you've followed
Jeremy D. Miller closely on Twitter you may have heard that the biggest
change in the new release has happened under the hood of StructureMap.
In previous versions StructureMap used Reflection.Emit to emit an
assembly for the construction of the types at runtime. This has been
completely rewritten using ExpressionTrees. I'm quite curious how he
implemented that. Feels like yet another source to learn has emerged ;-)
