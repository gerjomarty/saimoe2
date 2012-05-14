require 'spec_helper'

describe AlphabeticalPagination do
  it "should ask for more/correct variables" do
    ap = AlphabeticalPagination.new
    lambda { ap.get_data }.should raise_error("no_of_columns must be defined")
    ap.no_of_columns = 2
    lambda { ap.get_data }.should raise_error("relation must be defined")
    ap.relation = Character.ordered_by_main_series
    ap.secondary_method = :lol
    lambda { ap.get_data }.should raise_error("secondary_method must be a Proc")
    ap.secondary_method = nil
    lambda { ap.get_data }.should raise_error("letter_method must be a Proc")
    ap.letter_method = 'A'
    lambda { ap.get_data }.should raise_error("letter_method must be a Proc")
    ap.letter_method = Proc.new {|c| c.last_name || c.first_name || c.given_name }
    ap.default_letter = 6
    lambda { ap.get_data }.should raise_error("default_letter must be a String")
    ap.default_letter = nil
    lambda { ap.get_data }.should_not raise_error
  end

  context "three one-tier characters" do
    before :each do
      @series = create :series, name: "Series"
      @chars = [].tap do |chars|
        chars << create(:empty_character, first_name: "Alpha", last_name: "Alpha", main_series: @series)
        chars << create(:empty_character, first_name: "Beta", last_name: "Beta", main_series: @series)
        chars << create(:empty_character, first_name: "Charlie", last_name: "Charlie", main_series: @series)
      end
    end

    it "should return correct one-tier data" do
      ap = AlphabeticalPagination.new
      ap.no_of_columns = 3
      ap.relation = Character.ordered
      ap.letter_method = Proc.new {|c| c.last_name || c.first_name || c.given_name }

      data = ap.get_data
      data.size.should == 3
      data[0].should == {'A' => [@chars[0]]}
      data[1].should == {'B' => [@chars[1]]}
      data[2].should == {'C' => [@chars[2]]}
    end
  end

  context "six one-tier characters" do
    before :each do
      @series = create :series, name: "Series"
      @chars = [].tap do |chars|
        chars << create(:empty_character, first_name: "Alpha", last_name: "Alpha", main_series: @series)
        chars << create(:empty_character, first_name: "Foo", last_name: "Alpha", main_series: @series)
        chars << create(:empty_character, first_name: "Beta", last_name: "Beta", main_series: @series)
        chars << create(:empty_character, first_name: "Foo", last_name: "Beta", main_series: @series)
        chars << create(:empty_character, first_name: "Charlie", last_name: "Charlie", main_series: @series)
        chars << create(:empty_character, first_name: "Foo", last_name: "Charlie", main_series: @series)
      end
    end

    it "should return correct one-tier data" do
      ap = AlphabeticalPagination.new
      ap.no_of_columns = 3
      ap.relation = Character.ordered
      ap.letter_method = Proc.new {|c| c.last_name || c.first_name || c.given_name }

      data = ap.get_data
      data.size.should == 3
      data[0].should == {'A' => @chars[0..1]}
      data[1].should == {'B' => @chars[2..3]}
      data[2].should == {'C' => @chars[4..5]}
    end
  end

  context "three series and three characters in two tiers" do
    before :each do
      @series = [].tap do |series|
        series << create(:series, name: "A")
        series << create(:series, name: "B")
        series << create(:series, name: "C")
      end
      @chars = [].tap do |chars|
        chars << create(:empty_character, first_name: "Foo", main_series: @series[0])
        chars << create(:empty_character, first_name: "Bar", main_series: @series[1])
        chars << create(:empty_character, first_name: "Baz", main_series: @series[2])
      end
    end

    it "should return correct two-tier data" do
      ap = AlphabeticalPagination.new
      ap.no_of_columns = 3
      ap.relation = Character.ordered_by_main_series
      ap.secondary_method = Proc.new {|c| c.main_series }
      ap.letter_method = Proc.new {|c| c.main_series.name }

      data = ap.get_data
      data.size.should == 3
      data[0].should == {'A' => {@series[0] => [@chars[0]]}}
      data[1].should == {'B' => {@series[1] => [@chars[1]]}}
      data[2].should == {'C' => {@series[2] => [@chars[2]]}}
    end
  end
end