---
layout: post
title: "Oh my Faraday"
date: 2013-02-09 15:12
comments: true
categories: [social-network-api, hypermedia]
---
I'm pretty glad I didn't write any tests for my client architecture so far. Somehow I had the feeling that most of the code was going to be deleted. And guess what the feeling was right. Last week I replaced the complete middleware stack handling I described in the [previous post](/2013/01/13/http-plus-middlewarestack-equals-win/) with the [Faraday](https://github.com/lostisland/faraday) gem and its friends.

{% blockquote Faraday project site %}
Faraday is an HTTP client lib that provides a common interface over many adapters (such as Net::HTTP) and embraces the concept of Rack middleware when processing the request/response cycle.
{% endblockquote %}

Here's how it works: If you supply a block to `Faraday.new` you can use it to configure the stack.

```ruby
@connection = Faraday.new(url: base_uri, user_agent: 'social network client', headers: { accept: 'application/json' }) do |builder|
  builder.request   :json
  builder.request   :basic_auth, options[:user], options[:password]
  builder.request   :retry

  builder.response  :json, :content_type => /\b(json|json-home)$/
  builder.response  :mashify

  builder.use       :instrumentation
  builder.adapter   :typhoeus
end

#Like any other HTTP library
response = @connection.get('/users')
```
`Faraday` works pretty much like [Rack::Builder](https://github.com/rack/rack/wiki/\(tutorial\)-rackup-howto). You compose the request/response pipeline out of middlewares via the `use` method. They're composed from top to botton. `request` and `response` are just syntactic sugar for the configuration. `builder.request :json` is nothing more than `builder.use Faraday::Request::Json`, though it probably looks cooler the first way. Here's the [full commit](https://github.com/BjRo/social-network-api/commit/4601252cef90e5f934cdc842f846cce6cd462fd8) that introduced `Faraday` into the client.

The client is functional with this, but I lost all the caching capabilities. As I found out I couldn't use `Rack::Cache` as a middleware. The API's look similar, but the `env` hash which gets passed from middleware to middleware isn't. But in the end this wasn't a big problem. The [faraday-http-cache](https://github.com/plataformatec/faraday-http-cache) gem does exactly what I need. And here comes the beauty of the middleware based model: All that needs to be done on the client side is to add a new middleware and you're done!

```ruby
builder.use :http_cache, :file_store, Dir.pwd + '/tmp'
```
I cheated a bit though. When I re-ran the client against the server, it didn't cache. After a bit looking into the code of the `faraday-http-cache` gem I realized that I had to include `public` in the `Cache-Control` directive returned with my responses in order to make it integrate well with the gem.

```ruby
if stale?(etag: users, public: true)
 render json: users
end
```
After changing that everything worked as expected. I'm a bit undecided regarding the `Cache-Control: public`. For all I know this indicates that the response can be cached in shared public caches, which is probably something you often don't want for your client. `private` on the other hand indicates that content can be cached in the non-shared private cache of the client, which is in my opinion more appropriate for our scenario and a valid caching scenario. I guess it's a bug in the `faraday-http-cache` gem.

The full commit that introduced caching back into the client can be found [here](https://github.com/BjRo/social-network-api/commit/1757b73cc9fb0a88d9a27651fc3e80cef91d3a91). I also removed the `Request` base class in that commit, because it became unnecessary after the refactoring.

This is probably the end of the heavy client focus for a while. I think I've got a pretty good understanding now, how I would start with writing a client for a web API. Sure we haven't talked about Hypermedia much so far, but we'll catch up to that.

Next to the table on which I'm writing this post a sheet of paper is waiting to be used for a post. It's from last October, specifically from the [Dev Open Space 2012](http://devopenspace.de/2012/) in Leipzig. [Sergey Shishkin](http://shishkin.org/) and I used it to prepare a talk about Hypermedia. I won't surprise you when I reveal that it shows a Hypermedia graph. This is where we continue next time.
