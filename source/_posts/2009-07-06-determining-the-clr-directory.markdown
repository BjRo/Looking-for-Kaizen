---
author: BjRo
date: '2009-07-06 20:38:36'
layout: post
slug: determining-the-clr-directory
status: publish
title: Determining the CLR directory
wordpress_id: '365'
? ''
: - Utilities
  - Utilities
  - Utilities
  - Utilities
---

If you ever need to locate the directory of the CLR version which runs
your .NET application, this little helper might be exactly what you
need. At least it was exactly what I needed today ;-)

[code language="csharp"]
System.Runtime.InteropServices.RuntimeEnvironment.GetRuntimeDirectory();
[/code]
