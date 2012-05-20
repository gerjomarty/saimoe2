require 'spec_helper'

describe SoulmateSearch do
  context "badly defined model" do
    before :each do
      build_model :bad_dummy do
        attr_accessible :name
        string :name

        include SoulmateSearch
      end
      Soulmate::Loader.new(BadDummy.to_s).load([])
    end

    it "should fail when trying to add a record" do
      expect { BadDummy.create name: "Foo" }.to raise_error(NotImplementedError,
                                                            "soulmate_term needs to be overridden by the subclass")
    end
  end

  context "basically defined model" do
    before :each do
      build_model :basic_dummy do
        attr_accessible :name
        string :name

        include SoulmateSearch

        def soulmate_term
          self.name
        end
      end
      Soulmate::Loader.new(BasicDummy.to_s).load([])
    end

    it "should return matches" do
      dummy = BasicDummy.create name: 'Bar'
      Soulmate::Matcher.new(BasicDummy.to_s).matches_for_term("Bar", cache: false).should ==
          [{'id' => dummy.id, 'term' => 'Bar', 'data' => {}}]
      dummy2 = BasicDummy.create name: 'Bartholomew'
      Soulmate::Matcher.new(BasicDummy.to_s).matches_for_term("Bar", cache: false).sort_by {|h| h['id']}.should ==
          [{'id' => dummy.id, 'term' => 'Bar', 'data' => {}},
           {'id' => dummy2.id, 'term' => 'Bartholomew', 'data' => {}}].sort_by {|h| h['id']}
    end
  end

  context "complex model" do
    before :each do
      build_model :complex_dummy do
        attr_accessible :name, :email
        string :name
        string :email

        include SoulmateSearch

        def soulmate_term
          self.name
        end

        def soulmate_data
          {'email' => self.email}
        end
      end
      Soulmate::Loader.new(ComplexDummy.to_s).load([])
    end

    it "should return matches" do
      dummy = ComplexDummy.create name: "Baz", email: "Bar"
      Soulmate::Matcher.new(ComplexDummy.to_s).matches_for_term("Baz", cache: false).should ==
          [{'id' => dummy.id, 'term' => 'Baz', 'data' => {'email' => dummy.email}}]
    end
  end
end