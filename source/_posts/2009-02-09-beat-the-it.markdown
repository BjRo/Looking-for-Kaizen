---
author: BjRo
date: '2009-02-09 11:45:55'
layout: post
slug: beat-the-it
status: publish
title: Beat the It
wordpress_id: '279'
? ''
: - C#
  - C#
  - C# 3.0
  - C# 3.0
  - Domain Specific Languages
  - Domain Specific Languages
  - Testing
  - Testing
  - C# 3.0
  - C# 3.0
  - Testing
  - Testing
---

. . . or how one could implement the It-Syntax introduced by MSpec. If
you don't know what the hell I'm talking about take a look at this code.
(I don't know if that's the current MSpec syntax but I think you'll get
where I'd like to take you . . . ) [sourcecode language="csharp"]
[Description] public class
Transferring\_between\_from\_account\_and\_to\_account { static Account
fromAccount; static Account toAccount; Context before\_each =()=\> {
fromAccount = new Account {Balance = 1m}; toAccount = new Account
{Balance = 1m}; }; When the\_transfer\_is\_made =()=\> {
fromAccount.Transfer(1m, toAccount); }; It
should\_debit\_the\_from\_account\_by\_the\_amount\_transferred =()=\> {
fromAccount.Balance.ShouldEqual(0m); }; It
should\_credit\_the\_to\_account\_by\_the\_amount\_transferred =()=\> {
toAccount.Balance.ShouldEqual(2m); }; } [/sourcecode] What you'll see in
this post is part of a spike I did some month ago[while I was
considering](http://www.bjoernrochel.de/2008/11/27/a-new-syntax-for-xunitbddextensions/)
to move the xUnit.BDDExtensions syntax to something more GWT and MSpec
like. I finally decided against that, partially because I realized that
there is absolutely no need for a MSpec-Clone; partially because I'm
still not so happy with the implications / side effects of the syntax
(nearly everything in you spec needs to become static). Anyway,
[recently](http://blog.jpboodhoo.com/SlightAdditionToJpboodhoobdd.aspx)
JP Boodhoo introduced the same feature to his Jpboodhoo.bdd codebase. A
lot of the comments requested a more detailed description of how he
implemented that feature. While I can't answer that question, I can talk
about how I tackled that problem. So here we go! **Some prerequisites
first** If you wonder how such a sweet syntax is possible in C\#, here
are some clues:

-   It uses fields with ommited access modifiers (therefore private
    fields).
-   It, When, etc. are delegate types.
-   Field-initializers are used to specifiy the delegates inline. (and
    because Field-Initializers are run before the constructor you can
    only access static and no instance members here. Thats the
    sideeffect I mentioned earlier).

**A closer look at my spike** The following class is the heart of the
spike I implemented. It takes a blank object and uses reflection to
build an ISpecHandler instance which is ultimately used to run the
specification. [sourcecode language="csharp"] public class SpecFactory :
ISpecFactory { public ISpecHandler CreateSpecFrom(object candidate) {
var fields = candidate.AllFields(); return
fields.AllFixtureInitializers() .Then(fields.AllContextInitializers())
.Then(fields.AllContextFinalizers()) .Then(fields.BehaviorUnderTest())
.Then(fields.AllObservations())
.ThenFinally(fields.AllFixtureCleaners()); } } [/sourcecode] As you
might guess a lot of extension methods are used in here, together with
the composite pattern. Lets start be inspecting the AllFields()
extension method. [sourcecode language="csharp"] public static
IEnumerable AllFields(this object instance) { var mask =
BindingFlags.Instance | BindingFlags.Static | BindingFlags.NonPublic |
BindingFlags.FlattenHierarchy; return instance .GetType()
.GetFields(mask) .Select(x =\> new FieldInfoAdapter(x, instance)); }
[/sourcecode] As its name implies this method reflects all the fields
from the supplied object. It returns a collection of IFieldInfo objects.
IFieldInfo? Yes I introduced a little adapter here, which helped me to
introduce better test isolation in the spike code. [sourcecode
language="csharp"] public class FieldInfoAdapter : IFieldInfo { private
readonly FieldInfo fieldInfo; private readonly object host; public
FieldInfoAdapter(FieldInfo fieldInfo, object host) { this.fieldInfo =
fieldInfo; this.host = host; } public object ReadValue() { return
fieldInfo.GetValue(host); } public Type FieldType { get { return
fieldInfo.FieldType; } } public string Name { get { return
fieldInfo.Name; } } } [/sourcecode] And here is how the code that finds
all the It delegates was implemented. [sourcecode language="csharp"]
public static ISpecHandler AllObservations(this IEnumerable fields) {
return fields.AllHandlersOf().AsOne(); } private static IEnumerable
AllHandlersOf(this IEnumerable fields) { return fields .Where(field =\>
field.FieldType == typeof(HandlerType) &amp;amp;&amp;amp;
!field.Name.StartsWith("CS$")) .Select(field =\> new
SpecHandler((Delegate)field.ReadValue())); } private static ISpecHandler
AsOne(this IEnumerable specHandler) { return new
CompositeSpecHandler(specHandler); } [/sourcecode] The basic stuff
happens in the AllHandlersOf method which filters the supplied fields by
the fieldtype and also removes all compiler generated fields (which
start with "CS$" in their names). The content (aka the delegate) of each
field that is left is read and wrapped in a SpecHandler instance.
[sourcecode language="csharp"] public class SpecHandler : ISpecHandler {
private readonly Delegate handler; public SpecHandler(Delegate handler)
{ this.handler = handler; } public void Run() { try {
handler.DynamicInvoke(); } catch (TargetInvocationException e) { throw
e.InnerException.PreserveStackTrace(); } } } [/sourcecode] Last but not
least there is the Then extension method which uses the composite
pattern to wrap all found spec handlers into a single instance.
[sourcecode language="csharp"] public static ISpecHandler Then(this
ISpecHandler handler, ISpecHandler handlerToRunAfterwards) { return new
CompositeSpecHandler(new[] { handler, handlerToRunAfterwards }); }
[/sourcecode] **Conclusion** It's not as hard to implement such a syntax
in C\# as one might initially think. Although the code shown in this
post is only spike code and not considered production ready, you can
derive all what's necessary to implement such a syntax. Fields, omitted
access modifiers, Field-Initializers and Delegates are the basic parts
together with some reflection logic to execute the code.