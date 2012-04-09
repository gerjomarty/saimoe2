require 'spec_helper'

describe Match do
  it { should belong_to(:tournament) }
  it { should have_many(:match_entries) }

  it { should validate_presence_of(:stage) }
  it { should validate_numericality_of(:match_number) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:tournament_id) }
  it { should validate_numericality_of(:tournament_id) }

  it { should_not allow_value(:not_a_stage).for(:stage) }

  it "should not allow a weird group" do
    m = build :match, group: :weird_group
    m.valid?.should be_false
    m.errors.size.should == 1
    m.errors[:group][0].should == "is the wrong length (should be 1 characters)"
  end

  it "should not allow a group in a finals match" do
    m = build :quarter_final_match, group: :a
    m.valid?.should be_false
    m.errors.size.should == 1
    m.errors[:group][0].should == "must be nil for a final match"
  end
end
