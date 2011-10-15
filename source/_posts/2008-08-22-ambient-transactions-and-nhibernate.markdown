---
author: BjRo
date: '2008-08-22 17:29:30'
layout: post
slug: ambient-transactions-and-nhibernate
status: publish
title: Ambient transactions and NHibernate
wordpress_id: '24'
comments: true
footer: true
categories: [dotnet]
---

About two weeks ago we had some discussions in the german Alt.NET mailing list whether ambient transactions can be used in combination
with NHibernate, especially regarding performance implications of such an approach. Background of that discussion was that my colleague
[Sergey](http://shishkin.org) and I wanted to implement the repository pattern based on Linq 2 NHibernate in a way that exposes no NHibernate
dependency to a surrounding layer. Besides that we didn't want to dublicate the UnitOfWork pattern that NHibernate implements internally.
Because of that we decided to try out ambient transactions (`System.Transactions`) as our UnitOfWork. Sergey has already posted about
the design we're currently investigating, so I won't go into detail about that here. You can read more here:

-   [Repository Pattern revised](http://sergeyshishkin.spaces.live.com/blog/cns!9F19E53BA9C1D63F!263.entry)
-   [UnitOfWork Pattern revised](http://sergeyshishkin.spaces.live.com/blog/cns!9F19E53BA9C1D63F!265.entry)
-   [Specification Pattern revised](http://sergeyshishkin.spaces.live.com/blog/cns!9F19E53BA9C1D63F!264.entry)

We started with a simple test comparison between the behavior of `NHibernates` native `ITransactions` and NHibernate using
`TransactionScope` for transactions. What we noticed : 

FlushMode.Commit doesn't work when using ambient Transactions
----------------------------------------------------------------
The following (xUnit) test fails: 

``` csharp 
[Fact] 
public void Session_should_be_clean_after_commited_transaction() 
{ 
	using (var tx = new TransactionScope()) 
	{ 
		SaveTwoPatients(); 
		tx.Complete(); 
	}

	Session.IsDirty().ShouldBeFalse(); 
}
```
But this can be easily fixed like this: 

```csharp
[Fact] 
public void Session_should_be_clean_after_commited_transaction_Fixed()
{
	using (var tx = new TransactionScope()) 
	{
			Transaction.Current.TransactionCompleted += (s, e) =>
			{ 
				if (e.Transaction.TransactionInformation.Status == TransactionStatus.Committed)
				{ 
					Session.Flush(); 
					Session.Clear(); 
				}
			};
			
			SaveTwoPatients(); 
			tx.Complete(); 
	}
	
	Session.IsDirty().ShouldBeFalse(); }
```
For some reason ambient Transaction are FASTER than NHibernates native counter parts
--------------------------------------------------------------------------------------
We have also some tests that perform a transactional insert a 1000 times. The duration of those tests are
quite surprising. Have a look:

[![NHibernateTransactions]({{ root_url }}/images/posts/nhibernatetransactions.png)]({{ root_url }}/images/posts/nhibernatetransactions.png "NHibernate transactions")

This has nothing to do with jitting in the CLR or the order how test are executed. I double checked the durations and ran each test on his own.
I didn't expect that gap, but I'm also not a NHibernate pro. Any thoughts? I'll write more about our experiences with that approach soon.
Our concept looks good on paper and our first impressions are not disproving either, so stay tuned . . .
