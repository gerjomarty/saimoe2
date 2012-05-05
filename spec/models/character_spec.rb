require 'spec_helper'

describe Character do
  it { should belong_to(:main_series) }
  it { should have_many(:character_roles) }

  it { should validate_presence_of(:main_series_id) }

  it "should not allow no names" do
    character = build :empty_character
    character.should_not be_valid
    character.errors.size.should == 1
    character.errors[:base][0].should == "At least one name must be given"
  end

  describe "custom name finders" do
    before :each do
      @chars = create_list :character, 17
      @chars << create(:empty_character, first_name: 'Foo', last_name: 'Bar')
      @chars << create(:empty_character, first_name: 'Bar', last_name: 'Baz')
      @chars << create(:empty_character, last_name: 'Bar Baz')
    end

    it "should return 17 results for 'First Last'" do
      list = Character.find_all_by_name('First Last')
      list.size.should == 17
      list.should == @chars[0..16]
    end

    it "should return 1 result for 'Foo Bar'" do
      list = Character.find_all_by_name('Foo Bar')
      list.size.should == 1
      list.should == [@chars[17]]
      Character.find_by_name('Foo Bar').should == @chars[17]
    end

    it "should return 2 results for 'Bar Baz'" do
      list = Character.find_all_by_name('Bar Baz')
      list.size.should == 2
      list.should == @chars[18..19]
    end
  end

  describe "#ordered" do
    before :each do
      [["Mr", "Alpha", nil], ["Mr", "Bravo", nil], ["A", "Bravo", nil],
       ["Foxtrot", nil, nil], ["Golf", nil, nil], [nil, "Bravo", nil],
       [nil, "Golf", nil], [nil, nil, "Foxtrot"], [nil, nil, "Golf"]].shuffle.each do |names|
        create(:character, first_name: names[0], last_name: names[1], given_name: names[2])
      end
    end

    context "normally ordered" do
      subject { Character.ordered.all }

      its(:size) { should == 9 }
      its([0]) { should == Character.where(first_name: "Foxtrot", last_name: nil, given_name: nil).first! }
      its([1]) { should == Character.where(first_name: "Golf", last_name: nil, given_name: nil).first! }
      its([2]) { should == Character.where(first_name: "Mr", last_name: "Alpha", given_name: nil).first! }
      its([3]) { should == Character.where(first_name: "A", last_name: "Bravo", given_name: nil).first! }
      its([4]) { should == Character.where(first_name: "Mr", last_name: "Bravo", given_name: nil).first! }
      its([5]) { should == Character.where(first_name: nil, last_name: "Bravo", given_name: nil).first! }
      its([6]) { should == Character.where(first_name: nil, last_name: "Golf", given_name: nil).first! }
      its([7]) { should == Character.where(first_name: nil, last_name: nil, given_name: "Foxtrot").first! }
      its([8]) { should == Character.where(first_name: nil, last_name: nil, given_name: "Golf").first! }
    end

    context "reverse ordered" do
      subject { Character.ordered.reverse_order.all }

      its(:size) { should == 9 }
      its([8]) { should == Character.where(first_name: "Foxtrot", last_name: nil, given_name: nil).first! }
      its([7]) { should == Character.where(first_name: "Golf", last_name: nil, given_name: nil).first! }
      its([6]) { should == Character.where(first_name: "Mr", last_name: "Alpha", given_name: nil).first! }
      its([5]) { should == Character.where(first_name: "A", last_name: "Bravo", given_name: nil).first! }
      its([4]) { should == Character.where(first_name: "Mr", last_name: "Bravo", given_name: nil).first! }
      its([3]) { should == Character.where(first_name: nil, last_name: "Bravo", given_name: nil).first! }
      its([2]) { should == Character.where(first_name: nil, last_name: "Golf", given_name: nil).first! }
      its([1]) { should == Character.where(first_name: nil, last_name: nil, given_name: "Foxtrot").first! }
      its([0]) { should == Character.where(first_name: nil, last_name: nil, given_name: "Golf").first! }
    end
  end

  describe "#find_by_name_and_series" do
    before :each do
      @series_1 = create :series, name: 'Series 1'
      @series_2 = create :series, name: 'Series 2'
      @char_1 = create :character, main_series: @series_1
      create :character_role, character: @char_1, series: @series_1
      @char_2 = create :empty_character, first_name: 'Foo', main_series: @series_1
      create :character_role, character: @char_2, series: @series_1
      @char_3 = create :character, main_series: @series_2
      create :character_role, character: @char_3, series: @series_2
    end

    it "should return first character when given correct name and series" do
      Character.find_by_name_and_series("First Last", @series_1).should == @char_1
    end

    it "should return second character when given different name" do
      Character.find_by_name_and_series("Foo", @series_1).should == @char_2
    end

    it "should return nil when given second character with wrong series" do
      Character.find_by_name_and_series("Foo", @series_2).should be_nil
    end

    it "should return third character when given second series" do
      Character.find_by_name_and_series("First Last", @series_2).should == @char_3
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
