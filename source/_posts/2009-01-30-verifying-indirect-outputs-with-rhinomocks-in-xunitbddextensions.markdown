---
author: BjRo
date: '2009-01-30 23:51:31'
layout: post
slug: verifying-indirect-outputs-with-rhinomocks-in-xunitbddextensions
status: publish
title: Verifying indirect outputs with Rhino.Mocks in xUnit.BDDExtensions
wordpress_id: '258'
? ''
: - BDD
  - BDD
  - xUnit
  - xUnit
  - xUnit.BDDExtensions
  - xUnit.BDDExtensions
---

[This](http://weblogs.asp.net/sfeldman/archive/2009/01/29/factory-per-dto.aspx)
post by Sean Feldman was kind of an eye opener to me. It introduced me
to a feature of Rhino.Mocks I wasn't really aware of and helped to solve
a problem I was never able to solve in a really satisfying way.

As you might know xUnit.BDDExtensions is using Rhino.Mocks behind the
scenes, but hides a lot of the mechanics of the library. This was done
in order to eliminate a lot of the ceremony in a specification, so that
a writer of a specification could focus on its essence (Quote MASHUP
from JP and Jeremy D. Miller :-) ). However, especially when configuring
and verifying behaviors Rhino.Mocks still shines through (with all its
power).

So let's take a closer look at the problem I'm referring to. It has to
do with specifications which observe indirect outputs. The following
code is part of a little object-to-object-mapper I wrote some months
ago. [sourcecode language="csharp"] public class ExpressionBasedWriter :
IWriteStrategy { private readonly IExpressionHandler expressionHandler;
private readonly MemberExpression memberExpression; public
ExpressionBasedWriter( Expression memberSelector, IExpressionHandler
expressionHandler) { this.memberExpression = (MemberExpression)
memberSelector.Body; this.expressionHandler = expressionHandler; }
public void WriteTo(Target instance, object value) {
expressionHandler.Handle(new HandlerContext { TargetInstanceType =
instance.GetType(), TargetInstance = instance, ValueToWrite = value,
MemberSelector = memberExpression }); } } [/sourcecode]

It's not so important to understand the full context of the code. The
important part is in the body of the WriteTo() method. Do you see it? It
constructs an instance and passes it into an internal dependency. The
interesting question now is how to verify the indirect output passed to
the dependeny in a spec...

**Take 1: Overriding Equals and GetHashcode() in the indirect output
class.**

In case you correctly implemented both of these methods you could write
a spec, that looks like somewhat like this.

[sourcecode language="csharp"]
[Concern(typeof(ExpressionBasedWriter<,\>))] public class
When\_something\_is\_about\_to\_be\_written :
InstanceContextSpecification\> { private IExpressionHandler
expressionHandler; private Expression targetExpression; private TestDto1
target; private string valueToWrite; protected override void
EstablishContext() { targetExpression = x =\> x.StringProperty;
expressionHandler = Dependency(); target = new TestDto1(); valueToWrite
= "uninteresting value"; } protected override IWriteStrategy CreateSut()
{ return new ExpressionBasedWriter(targetExpression, expressionHandler);
} protected override void Because() { Sut.WriteTo(target, valueToWrite);
} [Observation] public void
should\_form\_a\_context\_and\_pass\_it\_to\_the\_actual\_expression\_handler()
{ expressionHandler.WasToldTo(x =\> x.Handle(new HandlerContext {
MemberSelector = (MemberExpression)targetExpression.Body, TargetInstance
= target, TargetInstanceType = target.GetType(), ValueToWrite =
valueToWrite })); } } [/sourcecode]

This works. Ok, but what I don't like about this solution is that I
expose the concrete HandlerContext class to the spec. Test isolation is
broken here. Besides I have to be very carefully with my implementation
of Equals in this case, although it might only be needed in the
specification.

**Take 2: Introduce a factory**

You can prevent the direct exposure of the specification to the concrete
HandlerContext by introducing a factory which abstacts the creation of
the HandlerContext class away.

[sourcecode language="csharp"] public class ExpressionBasedWriter :
IWriteStrategy { private readonly IExpressionHandler expressionHandler;
private readonly IHandlerContextFactory handleContextFactory; private
readonly MemberExpression memberExpression; public
ExpressionBasedWriter( Expression memberSelector, IExpressionHandler
expressionHandler, IHandlerContextFactory handleContextFactory) {
this.memberExpression = (MemberExpression) memberSelector.Body;
this.expressionHandler = expressionHandler; this.handleContextFactory =
handleContextFactory; } public void WriteTo(Target instance, object
value) { var context =
handleContextFactory.CreateContext(memberExpression, instance, value);
expressionHandler.Handle(context); } } [Concern(typeof
(ExpressionBasedWriter<,\>))] public class
When\_something\_is\_about\_to\_be\_written :
InstanceContextSpecification\> { private IExpressionHandler
expressionHandler; private IHandlerContext handlerContext; private
IHandlerContextFactory handlerContextFactory; private TestDto1 target;
private Expression targetExpression; private string valueToWrite;
protected override void EstablishContext() { targetExpression = x =\>
x.StringProperty; expressionHandler = Dependency();
handlerContextFactory = Dependency(); handlerContext = Dependency();
target = new TestDto1(); valueToWrite = "uninteresting value";
handlerContextFactory.WhenToldTo(x =\>
x.CreateContext((MemberExpression)targetExpression.Body, target,
valueToWrite)).Return(handlerContext); } protected override
IWriteStrategy CreateSut() { return new
ExpressionBasedWriter(targetExpression, expressionHandler,
handlerContextFactory); } protected override void Because() {
Sut.WriteTo(target, valueToWrite); } [Observation] public void
should\_call\_the\_context\_handler\_factory\_in\_order\_to\_create\_a\_context()
{ handlerContextFactory.WasToldTo(x =\>
x.CreateContext((MemberExpression)targetExpression.Body, target,
valueToWrite)); } [Observation] public void
should\_call\_the\_expression\_handler\_in\_order\_to\_handle\_the\_created\_context()
{ expressionHandler.WasToldTo(x =\> x.Handle(handlerContext)); } }
[/sourcecode]

Again, this works too. But is that really a path one should go?
Introducing an additional factory + interface everytime one encounters
an indirect output? Besides that, did you notice how the specification
kind of degraded? So much additional noise now in there. This one causes
me actually more pain than Take 1, which takes me to ...

**Take 3: A neat Rhino.Mocks feature**

Leave the code from Take 1 as it is. Here's how you can write the
specification, without exposing it to the concrete HandlerContext class
and without causing to much noise in the specification itself.

[sourcecode language="csharp"]
[Concern(typeof(ExpressionBasedWriter<,\>))] public class
When\_something\_is\_about\_to\_be\_written :
InstanceContextSpecification\> { private IExpressionHandler
expressionHandler; Expression targetExpression; private TestDto1 target;
private string valueToWrite; protected override void EstablishContext()
{ targetExpression = x =\> x.StringProperty; expressionHandler =
Dependency(); target = new TestDto1(); valueToWrite = "uninteresting
value"; } protected override IWriteStrategy CreateSut() { return new
ExpressionBasedWriter(targetExpression, expressionHandler); } protected
override void Because() { Sut.WriteTo(target, valueToWrite); }
[Observation] public void
should\_form\_a\_context\_and\_pass\_it\_to\_the\_actual\_expression\_handler()
{ expressionHandler.WasToldTo(x =\> x.Handle(Arg.Matches(matcher =\>
matcher.MemberSelector == targetExpression.Body &&
matcher.TargetInstance == target && matcher.TargetInstanceType ==
target.GetType() && matcher.ValueToWrite.Equals(valueToWrite)))); } }
[/sourcecode]

The interesting stuff happens around the generic Arg class. You can use
it to specify a callback with which the indirect output can be verified.

**Conclusion**

In the past I mostly did what I demonstrated with Take 1 when I
encountered a situation where I needed to verify indirect outputs.
Introducing a factory for this was never really an option for me. I
don't see a real benefit there. The generic argument matching
capabilities of Rhino.Mocks really close a gap for me and they're what
I'm going to use for solving similar situations from now on.

I hope I'm not the only kid on the street who didn't know that this
feature exists . . .
