Deepstruct
==========

An adapter that wraps common ruby data-structures and makes them look like proper Objects.

    struct = DeepStruct.wrap({"a" => { "b" => "bingo!"}})
    struct.a.b
      => "bingo!"


Installation
============

    gem install deepstruct

Or if you use the awesomeness that is bundler, you stick this in your Gemfile:

    gem "deepstruct"

Usage
=====

    struct = DeepStruct.wrap({:awesome => [1,2,3, {"a" => "hello from the abyss"}]})
    struct.awesome[3].a
      => "hello from the abyss"

You can also write back through the wrapper with indifferent access

    struct = DeepStruct.wrap({:a => 10, "b" => 20})
    struct.a = 10
    struct.b = 20
    struct
      => #<DeepStruct::HashWrapper {:a=>10, "b"=>20}> 

When you want to you can still use hash-style syntax when accessing your DeepStructs. These accessors implement indifferent access too.

    struct = DeepStruct.wrap({:a => {1 => 'One', 2 => 'Two'}})
    struct.a[1]
      => "One"
    struct["a"][1]
      => "One"
    struct["b"] = "Hello"
    struct[:b]
      => "Hello"
    struct.b
      => "Hello"

If DeepStruct is getting in your way, you can always get access to the raw content by unwrapping it:

    struct = Deepstruct.wrap({"hello => "world"})
    struct.unwrap
      => {"hello" => "world"}
  
DeepStruct is a perfect companion to your json-oriented application!

    struct = DeepStruct.wrap(JSON.parse('{"full_name": "Don Corleone"}'))
    puts struct.to_json
    {"full_name":"Don Corleone"}
