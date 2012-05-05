require 'spec_helper'

describe VoiceActor do
  it { should have_many(:voice_actor_roles) }

  it "should not allow no names" do
    va = build :empty_voice_actor
    va.should_not be_valid
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

  describe "#ordered" do
    before :each do
      [["Alpha", nil], ["Beta", nil], [nil, "Alpha"], [nil, "Beta"],
       ["A", "Beta"], ["B", "Beta"]].shuffle.each do |names|
        create :voice_actor, first_name: names.first, last_name: names.last
      end
    end

    context "normally ordered" do
      subject { VoiceActor.ordered.all }

      its(:size) { should == 6 }
      its([0]) { should == VoiceActor.where(first_name: "Alpha", last_name: nil).first! }
      its([1]) { should == VoiceActor.where(first_name: "Beta", last_name: nil).first! }
      its([2]) { should == VoiceActor.where(first_name: nil, last_name: "Alpha").first! }
      its([3]) { should == VoiceActor.where(first_name: "A", last_name: "Beta").first! }
      its([4]) { should == VoiceActor.where(first_name: "B", last_name: "Beta").first! }
      its([5]) { should == VoiceActor.where(first_name: nil, last_name: "Beta").first! }
    end

    context "reverse ordered" do
      subject { VoiceActor.ordered.reverse_order.all }

      its(:size) { should == 6 }
      its([5]) { should == VoiceActor.where(first_name: "Alpha", last_name: nil).first! }
      its([4]) { should == VoiceActor.where(first_name: "Beta", last_name: nil).first! }
      its([3]) { should == VoiceActor.where(first_name: nil, last_name: "Alpha").first! }
      its([2]) { should == VoiceActor.where(first_name: "A", last_name: "Beta").first! }
      its([1]) { should == VoiceActor.where(first_name: "B", last_name: "Beta").first! }
      its([0]) { should == VoiceActor.where(first_name: nil, last_name: "Beta").first! }
    end
  end
end
