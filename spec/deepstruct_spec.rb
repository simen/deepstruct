require 'spec_helper'
require 'json'

describe DeepStruct do
  it "wraps a simple hash" do
    struct = DeepStruct.wrap({:a => 1, :b => 2})
    struct.a.should eq(1)
    struct.b.should eq(2)
  end

  it "can unwrap a wrapped value" do
    DeepStruct.wrap([1]).unwrap.should eq [1]
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
    struct = DeepStruct.wrap([1, 2, 3, 4, 5])
    struct[3].should eq(4)
    struct.sort { |a, b| b <=> a }.should eq([5, 4, 3, 2, 1])
    struct.map(&:to_s).should eq(['1', '2', '3', '4', '5'])
  end

  it "wraps hashes nested within arrays" do
    struct = DeepStruct.wrap([1, {:a => "hello"}])
    struct[1].a.should eq('hello')
    struct[1].class.should eq(DeepStruct::HashWrapper)
  end

  it "wraps arrays nested within hashes" do
    struct = DeepStruct.wrap({:a => [1, 2, 3]})
    struct.a[1].should eq(2)
    struct.a.class.should eq(DeepStruct::ArrayWrapper)
  end

  it "supports being converted to json" do
    struct = DeepStruct.wrap({:a => [1, 2, 3]})
    struct.to_json.should eq('{"a":[1,2,3]}')
  end

  it "raises NoMethodError when reading missing keys" do
    -> { DeepStruct.wrap({}).not_there }.should raise_error(NoMethodError)
  end

  context "HashWrapper, hash-like methods" do
    it "can be used as a common ruby hash with indifferent access" do
      struct = DeepStruct.wrap({:a => "hello", 'b' => "world"})
      struct[:a].should eq "hello"
      struct['a'].should eq "hello"
      struct[:b].should eq "world"
      struct['b'].should eq "world"
      struct['a'] = "Mmkay"
      struct[:a].should eq "Mmkay"
      struct.has_key?("a").should be_true
    end

    it "can access non string/symbol elements via hashistic syntax" do
      struct = DeepStruct.wrap({1 => "One"})
      struct[1].should eq 'One'
      struct[2] = "Two"
      struct[2].should eq 'Two'
      struct['2'].should eq nil
    end
  end

  context "HashWrapper, #respond_to?" do
    it "responds to hash methods" do
      struct = DeepStruct.wrap({:a => true})
      struct.size.should eq(1)
      struct.respond_to?(:size).should be_true
    end

    it "responds to keys that are present as symbols" do
      struct = DeepStruct.wrap({:a => nil})
      struct.respond_to?(:a).should be_true
    end

    it "responds to keys that are present as strings" do
      struct = DeepStruct.wrap({'a' => nil})
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

  context "summarizing two wrappers" do
    it "should raise error for incompatible types" do
      hash_struct = DeepStruct.wrap({:a => "hello"})
      array_struct = DeepStruct.wrap(["world"])
      -> { hash_struct + array_struct }.should raise_error("incompatible wrapper types")
    end

    it "should sum hash" do
      struct1 = DeepStruct.wrap({:a => "hello"})
      struct2 = DeepStruct.wrap({:a => "world"})
      (struct1 + struct2).unwrap.should eq({:a => "world"})

      struct1 = DeepStruct.wrap({:a => "hello"})
      struct2 = DeepStruct.wrap({:b => "world"})
      (struct1 + struct2).unwrap.should eq({:a => "hello", :b => "world"})

      struct1 = DeepStruct.wrap({:a => [1, 2, 3]})
      struct2 = DeepStruct.wrap({:b => "world"})
      (struct1 + struct2).unwrap.should eq({:a => [1, 2, 3], :b => "world"})

      struct1 = DeepStruct.wrap({:a => [1, 2, 3]})
      struct2 = DeepStruct.wrap({[4, 5, 6] => "world"})
      (struct1 + struct2).unwrap.should eq({:a => [1, 2, 3], [4, 5, 6] => "world"})

      struct1 = DeepStruct.wrap({:a => [1, 2, 3]})
      struct2 = DeepStruct.wrap({"a" => "world"})
      (struct1 + struct2).unwrap.should eq({:a => [1, 2, 3], "a" => "world"})
    end

    it "should sum array" do
      struct1 = DeepStruct.wrap([1, 2, 3])
      struct2 = DeepStruct.wrap([4, 5, 6])
      (struct1 + struct2).unwrap.should eq([1, 2, 3, 4, 5, 6])
    end
  end

  context "comparing two structs" do
    it "should be equal" do
      struct1 = DeepStruct.wrap({:a => "hello"})
      struct2 = DeepStruct.wrap({:a => "hello"})
      (struct1 == struct2).should be_true

      struct1 = DeepStruct.wrap({:a => "hello", :b => "world"})
      struct2 = DeepStruct.wrap({:b => "world", :a => "hello"})
      (struct1 == struct2).should be_true

      struct1 = DeepStruct.wrap([1, 2, 3])
      struct2 = DeepStruct.wrap([1, 2, 3])
      (struct1 == struct2).should be_true

      struct1 = DeepStruct.wrap({:a => "hello", :b => {:a => 123, :b => 321}})
      struct2 = DeepStruct.wrap({:b => {:b => 321, :a => 123}, :a => "hello"})
      (struct1 == struct2).should be_true
    end
  end

  it "should raise error for duplicate keys" do
    struct = DeepStruct.wrap({:a => "hello", 'a' => "world"})
    pending do
      struct.a.should eq struct[:a]
    end
  end

end
