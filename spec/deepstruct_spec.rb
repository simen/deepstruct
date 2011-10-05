require 'spec_helper'
require 'json'

describe DeepStruct do
  it "wraps a simple hash" do
    struct = DeepStruct.wrap({:a => 1, :b => 2})
    struct.a.should eq(1)
    struct.b.should eq(2)
  end

  it "avoids wrapping common datatypes" do
    DeepStruct.wrap("hello").should eq ("hello")
    DeepStruct.wrap(1).should eq(1)
    DeepStruct.wrap(1.0).should eq(1.0)
  end

  it "implements indifferenct access" do
    struct = DeepStruct.wrap({:a => 1, "b" => 2})
    struct.a.should eq(1)
    struct.b.should eq(2)
  end

  it "writes back to the hash with the same key-type as the original hash" do
    struct = DeepStruct.wrap({:a => 1, "b" => 2})
    struct.a = 3
    struct.b = 4
    struct.a.should eq(3)
    struct.b.should eq(4)
    struct.keys.should_not include("a")
    struct.keys.should_not include(:b)
  end

  it "wraps nested hashes" do
    struct = DeepStruct.wrap({:a => {:b => {:c => "hello from deep space"}}})
    struct.a.b.c.should eq("hello from deep space")
  end

  it "wraps arrays and support all common operations" do
    struct = DeepStruct.wrap([1,2,3,4,5])
    struct[3].should eq(4)
    struct.sort{|a,b| b <=> a}.should eq([5,4,3,2,1])
    struct.map(&:to_s).should eq(['1', '2', '3', '4', '5'])
  end

  it "wraps hashes nested within arrays" do
    struct = DeepStruct.wrap([1, {:a => "hello"}])
    struct[1].a.should eq('hello')
    struct[1].class.should eq(DeepStruct::HashWrapper)
  end

  it "wraps arrays nested within hashes" do
    struct = DeepStruct.wrap({:a => [1,2,3]})
    struct.a[1].should eq(2)
    struct.a.class.should eq(DeepStruct::ArrayWrapper)
  end

  it "supports being converted to json" do
    struct = DeepStruct.wrap({:a => [1,2,3]})
    struct.to_json.should eq('{"a":[1,2,3]}')
  end

  context "HashWrapper, #respond_to?" do
    it "responds to hash methods" do
      struct = DeepStruct.wrap({:a => true})
      struct.size.should eq(1)
      struct.respond_to?(:size).should be_true
    end

    it "responds to keys that are present" do
      struct = DeepStruct.wrap({:a => nil})
      struct.respond_to?(:a).should be_true
    end

    it "doesn't respond to missing keys" do
      struct = DeepStruct.wrap({:a => true})
      struct.respond_to?(:b).should be_false
    end

    it "responds to keys that can be assigned to" do
      struct = DeepStruct.wrap({:a => true})
      struct.respond_to?(:a=).should be_true
    end
  end
end
