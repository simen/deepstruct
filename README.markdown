Deepstruct
==========

An adapter that wraps commond ruby data-structures and makes them look like regular ruby objects.

Installation
============

Not yet published as a gem, so you'll have to

  git clone git@github.com:simen/deepstruct.git
  cd deepstruct
  rake install

Or if you use the awesomeness that is bundler, you stick this in your Gemfile:

  gem "deepstruct", :git => git@github.com:simen/deepstruct.git

Usage
=====

  require 'deepstruct'
  struct = DeepStruct.wrap({:awesome => [1,2,3, {"a" => "hello from the abyss"}]})
  struct.awesome[3].a
    => "hello from the abyss"

You can also write back through the wrapper with indifferent access

  struct = DeepStruct.wrap({:a => 1, "b" => 2})
  struct.a = 10
  struct.b = 20
  struct
    => #<DeepStruct::HashWrapper {:a=>10, "b"=>20}> 
  
DeepStruct is a perfect companion to your json-oriented application!
