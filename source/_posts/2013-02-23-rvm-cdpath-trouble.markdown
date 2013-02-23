---
layout: post
title: "RVM CDPATH trouble"
date: 2013-02-23 12:06
comments: true
categories: [uncategorized]
---
[CDPATH](http://hints.macworld.com/article.php?story=2005031814311425) is one of those things I've become accustomed to over the last year and would wan't a shell without it anymore. In case you've never heard of it, it gives you the possiblity to quickly access your favorite directories from anywhere via the `cd` command.

But as I found out this morning a misconfigured `CDPATH` can lead to very strange behaviors with `RVM`. My `.zshrc` exported `CDPATH` like this:
```
export CDPATH=~/Coding/Laboratory/
```
That's the path to the folder where all my `git` repositories are located. People more versed with a shell environment probably already see the problem. If you try to install the latest `Ruby` binaries with `rvm install` using this configuration, it won't compile. It aborts with something like this:
```
/bin/sh: line 0: cd: ext/-test-/array/resize: No such file or directory
/bin/sh: line 0: cd: ext/-test-/add_suffix: No such file or directory
make[1]: *** [ext/-test-/array/resize/all] Error 1
make[1]: *** Waiting for unfinished jobs....
make[1]: *** [ext/-test-/add_suffix/all] Error 1
make: *** [build-ext] Error 2
```
A bit of google search finally lead me to the [solution](http://stackoverflow.com/questions/12885548/unable-to-build-ruby-1-9-3-on-lion). `.` needs to be in the `CDPATH` as well.

```
export CDPATH=.:~/Coding/Laboratory/
```

And finally I was able to compile. Good to know, even better to share :-)
