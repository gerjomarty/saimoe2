require 'spec_helper'

describe Series do
  it { should have_many(:main_characters) }
  it { should have_many(:character_roles) }

  it { should validate_presence_of(:name) }
  it { should allow_value('ABCDEF').for(:color_code) }
  it { should_not allow_value('khgrds').for(:color_code) }
  it { should_not allow_value('123').for(:color_code) }

  it "should upcase submitted color codes" do
    series = build(:series, color_code: '17dead')
    series.color_code.should == "17DEAD"
  end
end
