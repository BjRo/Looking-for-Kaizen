---
layout: post
title: "HTTP + client side middleware stack == Win"
date: 2013-01-13 12:11
comments: true
categories: [social-network-api, hypermedia]
---
Unbelievable how time flies by. Someone who doesn't know me personally, could've probably come to the conclusion that this little blog series has already halted before it even began in the meantime. Let me assure you that is not the case. I'm still invested in this project. Though I need to admit that things are progressing much slower than I originally had planed or hoped for.

So what is the current state of our journey? And what did I learn so far?

I started by building the most simple Rails based API I could think of. At the moment it's only capable of listing users and showing an individual user. It doesn't have any Hypermedia capabilities what so ever. It's uses the [Rails-API](https://github.com/rails-api/rails-api) for a slimmed down version of the Rails stack, [Devise](https://github.com/plataformatec/devise) for implementing HTTP Basic Authentication and the [faker](https://github.com/stympy/faker) gem to populate the development database with some test data.

##The home document

Then I added a minimal [home document](http://tools.ietf.org/html/draft-nottingham-json-home-02) that lists the servers resources and how they can be interacted with.  I implemented the specification as a mini DSL in Ruby, which is probably over the top, but was fun anyway.

``` ruby The initial version of the home document for my app https://github.com/BjRo/social-network-api/blob/master/social-network-server/app/models/api/home_document.rb Github
module Api
  HomeDocument = JsonHome::HomeDocument.define do
    resource 'urn:sna:rel:users' do
      href '/users'
    end

    resource 'urn:sna:rel:user' do
      href_template '/users/{user_id}'
      href_vars user_id: 'http://upcoming/documentation/page'
    end
  end
end
```
So what do you see here? This document lists both resources currently provided by the server app. They both got a unique name which in this case in an [URN](http://en.wikipedia.org/wiki/Uniform_Resource_Name). One of them (urn:sna:rel:users) has a fixed URL (/users). The other one (urn:sna:rel:user) uses an URI template ala [RFC6570](http://tools.ietf.org/html/rfc6570). It also lists all parameters that are contained in the template explicitly, together with a link to the documentation of that parameter.

This homedocument will be served at the entry point of the API, which in the case of my sample app is '/api'.

``` ruby routes.rb https://github.com/BjRo/social-network-api/blob/master/social-network-server/config/routes.rb Github
SocialNetworkServer::Application.routes.draw do
  devise_for :users, skip: :sessions

  get 'api', to: 'api/home_document#show'

  namespace "api" do
    resources :users, only: [:index, :show]
  end
end
```
If you query this URI you'll get the following response

```
$ curl -H 'Accept: application/json-home' -u 'test@test.de:testtest' http://localhost:3000/api

{
   "resources": [
   {
      "urn:sna:rel:users": {
        "href":"/users",
        "hints": {
          "allow":["GET"],
          "representations":["application/json"],
          "accept-ranges":[],
          "accept-put":[],
          "accept-post":[],
          "precondition-req":[],
          "prefer":[]
        }
      }
    },
    {
      "urn:sna:rel:user": {
        "href-template": "/users/{user_id}",
        "href-vars": {
          "user_id":"http://upcoming/documentation/page"
        },
        "hints": {
          "allow":["GET"], 
          "representations":["application/json"],
          "accept-ranges":[], 
          "accept-put":[],
          "accept-post":[],
          "precondition-req":[],
          "prefer":[]
        }
      }
    }]
}
```
There's obviously a lot more in there that we've specified in our DSL. That's because our DSL assumes some defaults when they're not configured. You can find the complete implementation of it [here](https://github.com/BjRo/social-network-api/tree/master/social-network-server/lib/json_home).

## The client
That's when I stopped working on the server part for a while and started working on a ruby based client. I've pointed this out in the intro of this blog series, but it's worth repeating. Understanding the client side as well as possible and being able to provide guidance, especially in times of transition from a more tranditional HTTP API to a more Hypermedia based approach, is one of my main motivations behind this series. That's why I'm building the client in parallel to the actual server part.

As usual the Ruby ecosystem was incredibly helpful to get a good start for the client implementation. The commandline client I've been building uses [Thor](https://github.com/wycats/thor) for the CLI, [Typhoeus](https://github.com/typhoeus/typhoeus) as the HTTP library and the [uri_template](https://github.com/hannesg/uri_template) gem for building up URIs from templates. The rest is more or less handrolled at the moment.

``` ruby The client side gems https://github.com/BjRo/social-network-api/blob/master/social-network-client/ruby/Gemfile Github
gem 'typhoeus'
gem 'thor'
gem 'ethon'
gem 'multi_json'
gem 'uri_template'
```
Some words upfront, before we take a look at the implementation. I didn't intend to build a browser-like client for the server in this iteration. My goal at this stage is merely understanding how the integration of a home document and the constraint of not building URIs themselves impacts the client. And how we can solve it that the impact on the rest of the client code isn't that high. 

So let's drill down into the current client design. Let's start at the API the client code (in our case the thor CLI interacts with). It looks like this.

``` ruby Our minimal client API https://github.com/BjRo/social-network-api/blob/master/social-network-client/ruby/lib/api.rb Github

require 'social_network_client/request_dispatcher'
require 'social_network_client/requests'
require 'social_network_client/middlewares'

module SocialNetworkClient

  class Api
    def initialize(base_uri, options)
      @dispatcher = RequestDispatcher.new(base_uri, Middlewares::Stack.for(options))
    end

    def users
      @dispatcher.dispatch(Requests::UsersRequest.new)
    end

    def user(user_id)
      @dispatcher.dispatch(Requests::UserRequest.new(user_id))
    end
  end

end
```
What is maybe interesting here, is that I took a design approach somewhat different to what I see in the typical client libraries out there. The API class is merely a wrapper around various invokations to a RequestDispatcher instance. The RequestDispatcher is the only place in the code that holds the base URI of the API (or in other words the endpoint where we can find our home document). All other URIs are specified relative to the entry point URI.

The dispatcher is configured with a stack of middlewares. Anyone who has done some Rails/Rack development probably already knows what it does, it's the same deal. We're going to take a closer look at this later in the post, because I consider it an interesting realization I had during the development.

What we also see here is that the requests to the server are explicitly modeled. So what do they do?

``` ruby The UsersRequest class https://github.com/BjRo/social-network-api/blob/master/social-network-client/ruby/lib/social_network_client/requests/users_request.rb Github
require 'social_network_client/relations'
require 'social_network_client/requests/base'

module SocialNetworkClient
  module Requests

    class UsersRequest < Base
      def prepare(home_document)
        #Relation::Users == 'urn:sna:rel:users'
        @target_uri = home_document.href(Relations::Users)
        self
      end

      def run(http, options)
        http.get(@target_uri, options)
      end
    end

  end
end
```
A request encapsulates the logic to build up a request from the home document. It's got two methods that're invoked by the dispatcher during request execution. The first one is prepare, in which the request class finds the target url for its relation. Remember the only thing the client is supposed to know about the URI scheme is the relation identifier. After obtaining the request it simply requests the target URI. The other request is probably a bit more interesting.

``` ruby The UserRequest class https://github.com/BjRo/social-network-api/blob/master/social-network-client/ruby/lib/social_network_client/requests/user_request.rb Github
require 'social_network_client/relations'
require 'social_network_client/requests/base'

module SocialNetworkClient
  module Requests

    class UserRequest < Base
      def initialize(user_id)
        @user_id = user_id
      end

      def identifier
        super + "##{@user_id}"
      end

      def prepare(home_document)
        @target_uri = home_document.href(Relations::User, user_id: @user_id)
        self
      end

      def run(http, options)
        http.get(@target_uri, options)
      end
    end

  end
end
```
It looks similar except three things. On the one hand it's parametrized with a user_id. Which is also used as some kind of identfier in the method with that exact name. Even more interesting is the interaction with the home_document in the prepare method. This is the place where the target URI is constructed from the URI template contained in the home document. 

As you might have guessed the home_document we're dealing with here isn't a deserialized JSON response, it's a proxy wrapped around it. This class encapsulates the logic of building up the target URIs from the home document received from the server. Its implementation looks like this:

``` ruby HomeDocumentProxy and the RelationProxy https://github.com/BjRo/social-network-api/blob/master/social-network-client/ruby/lib/social_network_client/home_document_proxy.rb Github
require 'uri_template'

module SocialNetworkClient

  class HomeDocumentProxy
    attr_reader :base_uri

    def initialize(base_uri, home_document)
      @base_uri = base_uri
      @home_document = home_document
    end

    def rel(rel_name)
      relation = @home_document['resources'].detect { |r| r[rel_name] }[rel_name]
      RelationProxy.new(self, relation)
    end

    def href(rel_name, options = nil)
      rel(rel_name).href(options)
    end
  end

  class RelationProxy
    def initialize(document, relation)
      @document = document
      @relation = relation
    end

    def href(options = nil)
      if options
        expand_path expand_template(options)
      else
        expand_path @relation['href']
      end
    end

    def expand_path(path)
      "#{@document.base_uri}#{path}"
    end

    def expand_template(options)
      URITemplate.new(@relation['href-template']).expand(options)
    end
  end

end
```
With this little piece falling into place, we can finally take a look at how the dispatcher is implemented who orchestrates the interaction between the home document and the requests.

``` ruby The RequestDispatcher https://github.com/BjRo/social-network-api/blob/master/social-network-client/ruby/lib/social_network_client/request_dispatcher.rb Github
require 'typhoeus'
require 'base64'
require 'json'
require 'forwardable'
require 'social_network_client/home_document_proxy'
require 'social_network_client/failed_api_request'
require 'social_network_client/requests/home_document_request'

module SocialNetworkClient

  class RequestDispatcher
    attr_reader :base_uri

    extend Forwardable
    def_delegators :Typhoeus, :get, :post, :put, :delete

    def initialize(base_uri, middleware)
      @base_uri = base_uri
      @middleware = middleware
    end

    def dispatch(request)
      run request.prepare(home_document)
    end

    def run(request)
      response = @middleware.run(self, request, {})
      raise FailedApiRequest.new(response) unless response.success?
      JSON.parse(response.response_body)
    end

    def home_document
      HomeDocumentProxy.new @base_uri, run(Requests::HomeDocumentRequest.new)
    end

  end
end
```

The RequestDispatcher is actually pretty forward and (at least on the surface) highly inefficient. At runtime it holds the configured base URI of the API and the reference to the actual HTTP library that is being used. When a request is dispatched, it requests the home document from the server before performing the actual request. Yes, everytime a server request is made the home document is also requested. I can already hear my colleagues from the mobile team staring at me and telling me 'Hangover' like: "Yeah, that's not going to happen!". 

But it's not bad as it looks. That's were the middleware stack comes into play.

``` ruby The middleware stack https://github.com/BjRo/social-network-api/blob/master/social-network-client/ruby/lib/social_network_client/middlewares.rb Github
Dir["#{File.dirname(__FILE__)}/middlewares/*.rb"].sort.each do |path|
  require "social_network_client/middlewares/#{File.basename(path, '.rb')}"
end
require 'social_network_client/cache'

module SocialNetworkClient
  module Middlewares
    class Stack
      def self.for(options)
        Defaults.new(
          Authenticator.new(
            ConditionalGet.new(Delegator.new, Cache.new),
            options[:user],
            options[:password]))
      end
    end
  end
end
```
It certainly doesn't look so polished like a Rails middleware stack, but it does the same. It keeps the nitty gritty details of authentication, defaulting accept headers and most importantly caching away from the actual client code (it's still reachable from the requests though in case it's needed). I'll spare you the details of the actual middlewares. You can take a look at them [here](https://github.com/BjRo/social-network-api/tree/master/social-network-client/ruby/lib/social_network_client/middlewares). We're only going to take a look at one of them, but before we do, we take a slight detour to the server.

## Back to the server app
One part that we as developers often overlook when talking about communication patterns between different involved parties is that certain technologies are optimized for certain ways of communication. In our case that means that the HTTP infrastructure provides all the means to deal with our chatty communication. We just need to use them. You don't need to build a highly sophisticated chaching solution yourself, HTTP has already a scheme for this. So let's add caching instructions to our server side.

``` ruby Adding caching instructions to the server side https://github.com/BjRo/social-network-api/blob/master/social-network-server/app/controllers/api/home_document_controller.rb Github
module Api

  class HomeDocumentController < ApiController
    def show
      @home_document = HomeDocument
      expires_in 1.hour, public: false
      if stale?(etag: @home_document)
        @home_document
      end
    end
  end

  class UsersController < ApiController

    def index
      users = User.all
      if stale?(etag: users)
        render json: users
      end
    end

    def show
      user = User.find(params[:id])
      if stale?(etag: user)
        render json: user
      end
    end

  end
end
```
So what did we add here? For the controller that serves the home document we added support for caching via expiration and/or via validation (Conditional GET support). A full discussion about HTTP caching is naturally out of scope for this post. The short story is that every response send by the server will now contain some HTTP caching information that can be used to make the communication more efficient, either by the client itself or some HTTP intermediaries (like caches).

For instance the 'expires_in' in the HomeDocumentController tells clients that it's safe to cache the response in their local private cache for an hour. It's probably safe to say that the home document doesn't change frequently (if we leave custom tailored home documents for authenticated users out for the moment). The 'stale?' method adds Conditional GET support to a controller.

Every response will now contain an 'ETag' header. This is typically some kind of checksum or calculated hash value that can be used to detect a change in the HTTP response body. When supplied with a request via the 'If-Non-Match' header, the server can now decide whether he really needs to send the response body back to the client or simply answers with a 304 response code (ala 'Yo dawg, nothing new for you on my side'), effectively saving bandwidth.

Those two caching techiques together can become a pretty powerful tool to make the chatty nature of a Hypermedia API less burdensome while still retaining its benefits.

## Back to the client
So how can we leverage caching on the client side? It would've been awesome if the HTTP client library provided this out of the box, but unfortunately most of the ones (including the one I've been using for the sample app so far) don't implement some sort of caching support). That's where the middleware in the client came handy.

``` ruby ETag caching in the client https://github.com/BjRo/social-network-api/blob/master/social-network-client/ruby/lib/social_network_client/middlewares/conditional_get.rb Github
module SocialNetworkClient
  module Middlewares
    class ConditionalGet
      def initialize(inner, cache)
        @inner = inner
        @cache = cache
      end

      def run(http, request, options)
        if entry = cache?(request)
          options[:headers].merge!('If-None-Match' => entry[:etag])
        end

        response = @inner.run(http, request, options)

        if response.modified?
          cache! request, response
        else
          response = entry[:response]
        end

        response
      end

      def cache?(request)
        @cache.resolve(request.identifier)
      end

      def cache!(request, response)
        @cache.store(
          request.identifier,
          etag: response.headers_hash['ETag'],
          response: response)
      end
    end
  end
end
```
That piece of code should explain why there's something like an identifier on a request instance. It's used as a lookup key for caching. Plugging this middleware into the stack will check whether  the related resource has been accessed previously. If so it sends the 'ETag' with the request.  The server either answers with a 304 and no content (then the content from the local cache can be used) or it answers with a new payload and the local cache needs to be updated.

#Conclusions
Well, Hypermedia wise we haven't implemented much yet. There's some things I learned while implementing the current state though. Most importantly that separating out an HTTP middleware stack from the other communication related code in the client can have a huge impact on the code itself. I really like how the code lays itself out at the moment. 

It's probably a bit overengineered, but I like the direction to which this is going. HTTP provides such a rich set of caching capabilities and also a lot of great debugging tools for the communication. If that is the case, why're we still building local (even relational) caches that neglect the nature of HTTP?

The interesting question though is why (at least in the Ruby space) does none of the HTTP client libraries implement HTTP caching? Any thoughts on this? 

One interesting idea (or so it seems) I would like to pursuit until my next post is whether we can use the Rack infrastructure especially Rack::Cache on the client side. A quick googling suggested that [Faraday](https://github.com/lostisland/faraday) might give me the integration between [Typhoeus](https://github.com/typhoeus/typhoeus) and [Rack::Cache](https://github.com/rtomayko/rack-cache) I'm looking for. If all goes well I should be able to get rid of my naive middleware stack implementation. We'll see ...

See you next time around!
