require 'spec_helper'

describe VoiceActor do
  it "should not allow no names" do
    va = build :empty_voice_actor
    va.valid?.should be_false
    va.errors.size.should == 1
    va.errors[:base][0].should == "At least one name must be given"
  end

  describe "#full_name" do
    it "should return first/last name if they exist" do
      va = build :voice_actor
      va.full_name.should == "First Last"
    end

    it "should return last name if only that exists" do
      va = build :voice_actor_with_last_only
      va.full_name.should == "Last"
    end
  end
end
