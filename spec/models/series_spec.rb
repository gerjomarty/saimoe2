require 'spec_helper'

describe Series do
  it { should validate_presence_of(:name) }

  it "should not allow out of range color code" do
    series = build :series_with_incorrect_color_code
    series.valid?.should be_false
    series.errors.size.should == 1
    series.errors[:color_code][0].should == "is invalid"
  end

  it "should upcase submitted color codes" do
    series = build(:series, color_code: '17dead')
    series.color_code.should == "17DEAD"
  end
end
