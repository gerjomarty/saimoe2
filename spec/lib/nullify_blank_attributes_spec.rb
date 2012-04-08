require 'spec_helper'

describe NullifyBlankAttributes do
  before :each do
    build_model :dummy do
      attr_accessible :name
      string :name
    end
  end

  it "should save variables with presence" do
    dummy = Dummy.new name: 'Hello'
    dummy.name.should == 'Hello'
  end

  it "should nullify variables with no presence" do
    dummy = Dummy.new name: ''
    dummy.name.should == nil
  end
end