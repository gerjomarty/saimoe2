require 'spec_helper'

describe Appearance do
  it { should belong_to(:character_role) }
  it { should belong_to(:tournament) }
  it { should have_many(:match_entries) }
  it { should have_many(:voice_actor_roles) }

  it { should validate_presence_of(:character_role_id) }
  it { should validate_numericality_of(:character_role_id).only_integer }
  it { should validate_presence_of(:tournament_id) }
  it { should validate_numericality_of(:tournament_id).only_integer }

  describe "should only allow one character appearance per tournament" do
    before :each do
      @tournament = create :tournament
      @char_role = create :character_role
      create :appearance, tournament: @tournament, character_role: @char_role
    end

    it "with same character role" do
      app = build :appearance, tournament: @tournament, character_role: @char_role

      app.valid?.should be_false
      app.errors.size.should == 1
      app.errors[:base][0].should == "Character can only appear once per tournament"
    end

    it "with differing character roles" do
      char_role = create :character_role, character: @char_role.character
      app = build :appearance, tournament: @tournament, character_role: char_role

      app.valid?.should be_false
      app.errors.size.should == 1
      app.errors[:base][0].should == "Character can only appear once per tournament"
    end
  end
end
