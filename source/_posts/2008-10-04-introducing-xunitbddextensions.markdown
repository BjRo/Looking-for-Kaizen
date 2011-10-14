---
author: BjRo
date: '2008-10-04 13:28:31'
layout: post
slug: introducing-xunitbddextensions
status: publish
title: Introducing xUnit.BDDExtensions
wordpress_id: '143'
? ''
: - BDD
  - BDD
  - Testing
  - Testing
  - xUnit
  - xUnit
  - BDD
  - BDD
  - xUnit
  - xUnit
  - xUnit.BDDExtensions
  - xUnit.BDDExtensions
---

xUnit.BDDExtensions is a little framework build on top of xUnit which
enables a BDD style of testing with xUnit. Besides an emphasis on a
"test case class per fixture" organization scheme for tests, AAA
(Arrange, Act and Assert) style of writing tests and left to right
assertions, this framework also provides Rhino.Mocks integration out of
the box. By hiding the mechanics of Rhino.Mocks (record and replay
model, mocks vs. stubs) behind the scenes, xUnit.BDDExtensions also
helps on writing cleaner, easier to understand and less brittle tests
xUnit.BDDExtensions is based on JP Boodhoos BDD extensions for MBUnit
used in his "Nothing but .NET" bootcamps.

**Enough of the talking, let's look at some code**

This is actual code of the xUnit.BDDExtensions trunk. The
*SpecificationTestCommand*class serves as a kind of adapter inside
xUnit. It enables the test class to have methods that are run before and
after the actual test method is executed.\* [sourcecode
language="csharp"] public class SpecificationTestCommand :
BeforeAfterCommand { public SpecificationTestCommand( ITestCommand
innerCommand, MethodInfo testMethod) : base(innerCommand, testMethod) {
} public override MethodResult Execute(object testClass) { var
specification = testClass as ITestSpecification; try { if (specification
== null) { throw new InvalidOperationException( "Instance does not
implement ITestSpecification"); }
specification.InitializeSpecification(); return base.Execute(testClass);
} finally { if (specification != null) {
specification.CleanupSpecification(); } } } } [/sourcecode] Notice
several things:

1.  It expects the instance to implement *ITestSpecification*.
2.  It calls the *InitializeSpecification()* method on it
3.  Passes the execution to the inner command (in *base.Execute(obj)*)
4.  and finally cleans up the specification by calling
    *CleanupSpecification()*on it.

So how can a completely isolated happy path test for this look like?
[sourcecode language="csharp"]
[Concern(typeof(SpecificationTestCommand))] public class
when\_a\_specification\_test\_command\_is\_executed\_on\_a\_ITestSpecification\_implementer
: concern\_for\_specification\_test\_command { private MethodResult
expectedTestResult; private ITestCommand innerCommand; private
MethodInfo methodInfo; private MethodResult testResult; private
ITestSpecification testSpecification; protected override void
EstablishContext() { innerCommand = Dependency(); testSpecification =
Dependency(); methodInfo = GetTestMethodHandle(); expectedTestResult =
CreateMethodResult(methodInfo); innerCommand.WhenToldTo(x =\>
x.Execute(testSpecification)) .Return(expectedTestResult); } protected
override SpecificationTestCommand CreateSut() { return new
SpecificationTestCommand(innerCommand, methodInfo); } protected override
void Because() { testResult = Sut.Execute(testSpecification); }
[Observation] public void
should\_ask\_the\_test\_specification\_to\_initialize() {
testSpecification.WasToldTo(x =\> x.InitializeSpecification()); }
[Observation] public void
should\_pass\_the\_test\_specification\_to\_the\_inner\_test\_command()
{ innerCommand.WasToldTo(x =\> x.Execute(testSpecification)); }
[Observation] public void
should\_return\_the\_test\_result\_from\_the\_inner\_test\_command() {
testResult.ShouldBeEqualTo(expectedTestResult); } [Observation] public
void should\_ask\_the\_test\_specification\_to\_cleanup() {
testSpecification.WasToldTo(x =\> x.CleanupSpecification()); } }
[/sourcecode] Notice several things:

1.  In the *EstablishContext()* method the whole context for the test is
    created. This includes creating most of the dependencies with
    Rhino.Mocks through *Dependeny()* and the necessary configuration of
    their behavior. This is done in order to quickly get from an
    interaction based style of testing to a state based style of
    testing. In AAA terms this method implements the Arrange part.
2.  The *CreateSut()* method is executed after *EstablishContext()* and
    creates the actual system under test.
3.  The *Because()* method implements the actual behavior under test. In
    AAA terms this is the Act part. In the current example this meant
    executing the test command with an instance implementing the
    expected interface.
4.  Each method marked with the *ObservationAttribute* contains a single
    observation which should be fulfilled when the test has been
    executed. In AAA terms every Observation is an Assert.

That's basically it. Pretty straight forward imho. If I managed to make
you at least a bit curious about this style of testing, you can grab the
source with any Subversion client from:
`http://xunitbddextensions.googlecode.com/svn/trunk/`

Enjoy coding \* I know xUnit dropped this behavior in favor of the
dispose pattern, but having explicit, non technically named methods for
that still seems more natural in the context of BDD to me.
