require 'spec_helper'
require 'delegate'

class PassingTheBuck < SimpleDelegator
end

describe DeepStruct do

  specify "HashWrapper can be delegated to" do
    buck = DeepStruct.wrap(:for_sure => 'hell, yeah!')

    thing = PassingTheBuck.new(buck)
    thing.for_sure.should eq('hell, yeah!')
  end

end
