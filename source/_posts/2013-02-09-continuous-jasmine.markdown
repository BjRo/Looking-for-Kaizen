---
layout: post
title: "Continuous Jasmine"
date: 2013-02-09 16:48
comments: true
categories: [Testing, JS]
---
After lots of years I've currently the pleasure of working on a Javascript heavy application again. Last time when I worked with Javascript, there was no `Backbone`, no `Underscore`, not even a `JQuery`. Yes, that long ago and it sucked that much for me that I stayed away from the frontend side of things like the devil from water in the following years. 

Everybody should be able to get a second chance in life, so when the option came up I thought to myself: "Hey, why not. Let's give it a try". Javascript has come a long way since those old times. It's actually a pretty decent coding environment today. Aestetically it's still nowhere close to my personal favorites Ruby and FSharp, but it's at least ok :)

One thing that has also changed since the last time I did Javascript is my willingness to write code that isn't backed up by some sort of automated testing. It's virtually non existent. I know I'm a bit of a hardliner with this, but I consider that part of being a professional developer. So I went out to see what I would use to test my Javascript code and I settled with [Jasmine](http://pivotal.github.com/jasmine/). That should come to no surprise since I'm a big fan of [Rspec](http://rspec.info/) and [MSpec](https://github.com/machine/machine.specifications) as well.

#The Jasmine gem
I experimented with several setups to execute the Jasmine specs. Please note that I've no problem with a Ruby dependency and honestly, I didn't bother to search for Node based solutions. I finally settled with the [Jasmine](https://github.com/pivotal/jasmine-gem) gem. 

It brings some interesting things to the table. First of all it frees you from managing the `SpecRunner.html` directly. You don't have to include spec files manually any more. Secondly and more interesting it comes along with some `rake` tasks for running the specs in a CI environment.  After installing the gem, all you need to do is to run `$ jasmine init`. This will create the project structure for you, including a `rakefile` which sets up the `rake` interface.

`$ rake jasmine` builds your spec runner file, hosts it inside a `Webrick` instance and opens a browser showing the specs. That's nice, but I don't want to have to reload the browser manually everytime I change a file. That would be tedious. 

`$ rake jasmine:ci` is also interesting. It uses `rspec` and `selenium` to fire up the tests, grab the test results from the browser and display them back in the console. It works pretty well for a continuous integration scenario, but it's also slow as hell. Let's say the output in the console could also be optimized.

One thing I stumbled over, is a bug in the current version `1.3.1`. It relies on `yaml`, but doesn't seem to require it. You can work around it partially by manually requiring it in the `rakefile`, but this doesn't work for the `jasmine:ci` task. You can fix this by pinning the version in your `Gemfile` to `1.3.0` until the problem is fixed.

```ruby Gemfile
source :rubygems

group :development, :test do
  gem 'rake'
  gem 'jasmine', '=1.3.0'
end
```

#Jasmine.vim
What is nice, though, it's that if you're a `vim` user, you can use [Jasmine.vim](https://github.com/claco/jasmine.vim) which comes with keybindings and vim commands for those `rake` tasks plus syntax highlighters and lots of useful Jasmine snippets.

I played around with it for an hour and came to the conclusion that although the technical integration is nice, the feedback loop is practically unusable. It reminded me of the moment when I started a test in the first legacy Rails app I encountered and stared into the screen, waiting for something to happen and waiting and waiting. That's not how a feedback loop is supposed to be.

So I asked [@derickbailey](https://twitter.com/derickbailey), the guy that produces the excellent [Watch me code](http://www.watchmecode.net/) screencasts, what setup he uses in the screencasts. That looked pretty ideal.

#Enter guard + livereload

He had `vim` and a browser window open side by side and whenever he saved a file in vim, the browser window automatically refreshed and rerun his specs. Fast and snappy. That's how I wanted my feedback loop to be as well.

It's actually pretty easy to setup. You need [guard-livereload](https://github.com/guard/guard-livereload) and the [livereload Chrome extension](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei).  Just add `guard-livereload` to your `Gemfile` and run `$ bundle install`. 

```ruby Gemfile
source :rubygems

group :development, :test do
  gem 'rake'
  gem 'jasmine', '=1.3.0'
  gem 'rb-fsevent'
  gem 'guard-livereload'
end
```

`rb-fsevent` is needed to monitor filesystem changes on `OSX` which powers my development machine. After that, all you need to do configuration wise is to run `guard init livereload`, which will add a `Guardfile` to your project containing the configuration for `guard-livereload`.  You need to tweek it a bit to match the project structure, but that's easily done.

```ruby Guardfile
guard 'livereload' do
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{spec/.+\.(css|js|html)})
end
```

Next up you need to install the browser plugin. The one for `Chrome` can be found [here](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei). Be sure to be logged in with your Google account. I don't know why, but the extension won't install without that and gives you a nasty `CRX_MAGIC_NUMBER_INVALID` error instead. What a lovely error message. When installed you should see a new circle button in your `Chrome` toolbar.

Now that we've got all the pieces together, you can run the development server in one window by running `$ rake jasmine` and start `guard` with `$ guard start`. Once that has been done, you need to open the `root url` of your development server in the `Chrome` browser and click the `livereload` circle button. In the `guard` console there should now be a notification that a new browser has been connected. 

You're now ready to go and TDD the shit out of your Javascript project ...

