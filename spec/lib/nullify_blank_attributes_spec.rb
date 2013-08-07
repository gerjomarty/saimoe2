require 'spec_helper'

describe NullifyBlankAttributes do
  before :each do
    build_model :dummy do
      attr_accessible :name, :is_alive
      string :name
      bool :is_alive
    end
  end

  it "should save variables with presence" do
    dummy = Dummy.new name: 'Hello', is_alive: true
    dummy.name.should == 'Hello'
  end

  it "should nullify variables with no presence" do
    dummy = Dummy.new name: '', is_alive: true
    dummy.name.should == nil
  end

  it "should not nullify boolean false variable" do
    dummy = Dummy.new name: 'Hello', is_alive: false
    dummy.is_alive.should == false
  end
end