require 'spec_helper'

describe Tournament do
  it { should have_many(:appearances) }
  it { should have_many(:matches) }

  it { should validate_presence_of(:year) }
  it { should allow_value('2046').for(:year) }
  it { should_not allow_value('201').for(:year) }
  it { should_not allow_value('ABCD').for(:year) }
  it { should validate_presence_of(:group_stages) }
  it { should validate_presence_of(:final_stages) }
  it { should serialize(:group_stages).as(Array) }
  it { should serialize(:final_stages).as(Array) }
  it { should_not allow_value({this_is: :a_hash}).for(:group_stages) }
  it { should_not allow_value([:not_a_stage, :round_1]).for(:group_stages) }
  it { should_not allow_value([:round_1, :quarter_final]).for(:group_stages) }
  it { should allow_value([:round_1, :round_2]).for(:group_stages) }
  it { should_not allow_value({this_is: :a_hash}).for(:final_stages) }
  it { should_not allow_value([:again_not_a_stage, :final]).for(:final_stages) }
  it { should_not allow_value([:quarter_final, :round_3]).for(:final_stages) }
  it { should allow_value([:quarter_final, :semi_final]).for(:final_stages) }

  it "validates uniqueness of year" do
    create :tournament
    should validate_uniqueness_of(:year)
  end

  describe "#fy" do
    t = FactoryGirl.create(:tournament)
    Tournament.fy(2000).should == t
  end
end
