---
author: BjRo
date: '2008-08-22 17:29:30'
layout: post
slug: ambient-transactions-and-nhibernate
status: publish
title: Ambient transactions and NHibernate
wordpress_id: '24'
? ''
: - NHibernate
  - NHibernate
  - xUnit
  - xUnit
  - Ambient transactions
  - Ambient transactions
  - NHibernate
  - NHibernate
  - xUnit
  - xUnit
---

About two weeks ago we had some discussions in the german Alt.NET
mailing list whether ambient transactions can be used in combination
with NHibernate, especially regarding performance implications of such
an approach. Background of that discussion was that my colleague
[Sergey](http://shishkin.org) and I wanted to implement the repository
pattern based on Linq 2 NHibernate in a way that exposes NO NHibernate
dependency to a surrounding layer. Besides that we didn't want to
dublicate the UnitOfWork pattern that NHibernate implements internally.
Because of that we decided to try out ambient transactions
(System.Transactions) as our UnitOfWork. Sergey has already posted about
the design we're currently investigating, so I won't go into detail
about that here. You can read more here:

-   [RepositoryPatter
    revised](http://sergeyshishkin.spaces.live.com/blog/cns!9F19E53BA9C1D63F!263.entry)
-   [UnitOfWork Pattern
    revised](http://sergeyshishkin.spaces.live.com/blog/cns!9F19E53BA9C1D63F!265.entry)
-   [Specification Pattern
    revised](http://sergeyshishkin.spaces.live.com/blog/cns!9F19E53BA9C1D63F!264.entry)

We started with a simple test comparison between the behavior of
NHibernates native ITransactions and an NHibernate using
TransactionScope for transactions.Â What we noticed : **FlushMode.Commit
doesn't work when using ambient Transactions** The following (xUnit)
test fails: [sourcecode language='csharp'] [Fact] public void
Session\_should\_be\_clean\_after\_commited\_transaction() { using (var
tx = new TransactionScope()) { SaveTwoPatients(); tx.Complete(); }
Session.IsDirty().ShouldBeFalse(); } [/sourcecode] But this can be
easily fixed like this: [sourcecode language='csharp'] [Fact] public
void Session\_should\_be\_clean\_after\_commited\_transaction\_Fixed() {
using (var tx = new TransactionScope()) {
Transaction.Current.TransactionCompleted += (s, e) =\> { if
(e.Transaction.TransactionInformation.Status ==
TransactionStatus.Committed) { Session.Flush(); Session.Clear(); } };
SaveTwoPatients(); tx.Complete(); } Session.IsDirty().ShouldBeFalse(); }
[/sourcecode] **For some reason ambient Transaction are FASTER than
NHibernates native counter parts** We have also some testsÂ that perform
a transactional insert a 1000 times. The duration of those tests are
quite surprising. Have a look:
[![NHibernateTransactions](http://www.bjoernrochel.de/wp-content/uploads/2008/08/nhibernatetransactions.png)](http://www.bjoernrochel.de/wp-content/uploads/2008/08/nhibernatetransactions.png "NHibernateTransactions")
This has nothing to do with jitting in the CLR or the order how test are
executed. I double checked the durations and ran each test on his own.Â
I didn't expect that gap, but I'm also not a NHibernate pro. Any
thoughts? I'll write more about our experiences with that approach soon.
Our concept looks good on paper and our first impressions are not
disproving either, so stay tuned . . .
