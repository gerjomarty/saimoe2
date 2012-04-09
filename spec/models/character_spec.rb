require 'spec_helper'

describe Character do
  it { should belong_to(:main_series) }
  it { should have_many(:character_roles) }

  it { should validate_presence_of(:main_series_id) }
  it { should validate_numericality_of(:main_series_id) }

  it "should not allow no names" do
    character = build :empty_character
    character.valid?.should be_false
    character.errors.size.should == 1
    character.errors[:base][0].should == "At least one name must be given"
  end

  describe "#characters_for_name" do
    before :each do
      @chars = create_list :character, 17
      @chars << create(:empty_character, first_name: 'Foo', last_name: 'Bar')
      @chars << create(:empty_character, first_name: 'Bar', last_name: 'Baz')
      @chars << create(:empty_character, last_name: 'Bar Baz')
    end

    it "should return 17 results for 'First Last'" do
      list = Character.characters_for_name('First Last').all
      list.size.should == 17
      list.should == @chars[0..16]
    end

    it "should return 1 result for 'Foo Bar'" do
      list = Character.characters_for_name('Foo Bar').all
      list.size.should == 1
      list.should == [@chars[17]]
    end

    it "should return 2 results for 'Bar Baz'" do
      list = Character.characters_for_name('Bar Baz').all
      list.size.should == 2
      list.should == @chars[18..19]
    end
  end

  describe "#full_name" do
    it "should return first/last name if they exist" do
      character = build :character
      character.full_name.should == "First Last"
    end

    it "should return first name if only first there" do
      character = build :character_with_first_only
      character.full_name.should == "First"
    end

    it "should return given name if only given there" do
      character = build :character_with_given_only
      character.full_name.should == "Given"
    end
  end
end
