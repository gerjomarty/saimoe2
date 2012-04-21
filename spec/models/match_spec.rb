require 'spec_helper'

describe Match do
  it { should belong_to(:tournament) }
  it { should have_many(:match_entries) }

  it { should validate_presence_of(:stage) }
  it { should validate_numericality_of(:match_number).only_integer }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:tournament_id) }
  it { should validate_numericality_of(:tournament_id).only_integer }

  it { should_not allow_value(:not_a_stage).for(:stage) }

  it "should allow a valid group in a group match" do
    m = build :match, group: :a
    m.valid?.should be_true
  end

  it "should not allow a weird group" do
    m = build :match, group: :weird_group
    m.valid?.should be_false
    m.errors.size.should == 1
    m.errors[:group][0].should == "is not a valid group"
  end

  it "should not allow a group in a finals match" do
    m = build :quarter_final_match, group: :a
    m.valid?.should be_false
    m.errors.size.should == 1
    m.errors[:group][0].should == "must be nil for a final match"
  end

  describe "#group_match?" do
    it "should return true when a group match" do
      m = build :match
      m.group_match?.should be_true
    end

    it "should return false when a final match" do
      m = build :quarter_final_match
      m.group_match?.should be_false
    end
  end

  describe "#final_match?" do
    it "should return false when a group match" do
      m = build :match
      m.final_match?.should be_false
    end

    it "should return true when a final match" do
      m = build :quarter_final_match
      m.final_match?.should be_true
    end
  end
end
