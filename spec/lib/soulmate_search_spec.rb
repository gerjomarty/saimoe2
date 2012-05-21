require 'spec_helper'

describe SoulmateSearch do
  context "badly defined model" do
    before :each do
      build_model :bad_dummy do
        attr_accessible :name
        string :name

        include SoulmateSearch
      end
      BadDummy.loader.load([])
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
      BasicDummy.loader.load([])
    end

    it "should return matches" do
      dummy = BasicDummy.create name: 'Bar'
      BasicDummy.matcher.matches_for_term('Bar', cache: false).should ==
          ['id' => dummy.id, 'term' => 'Bar', 'data' => {}]
      dummy2 = BasicDummy.create name: 'Bartholomew'
      BasicDummy.matcher.matches_for_term('Bar', cache: false).sort_by {|h| h['id']}.should ==
          [{'id' => dummy.id, 'term' => 'Bar', 'data' => {}},
           {'id' => dummy2.id, 'term' => 'Bartholomew', 'data' => {}}].sort_by {|h| h['id']}
      dummy.destroy
      BasicDummy.matcher.matches_for_term('Bar', cache: false).should ==
          ['id' => dummy2.id, 'term' => 'Bartholomew', 'data' => {}]
    end

    it "should return properly formatted results from search" do
      dummy = BasicDummy.create name: 'Bar'
      dummy2 = BasicDummy.create name: 'Bartholomew'
      BasicDummy.search('Bar').sort_by {|h| h[:id]}.should ==
          [{id: dummy.id, value: 'Bar', label: 'Bar'},
           {id: dummy2.id, value: 'Bartholomew', label: 'Bartholomew'}].sort_by {|h| h[:id]}
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

        def self.soulmate_label_for id, term, data
          "term #{term} for data #{data['email']}"
        end
      end
      ComplexDummy.loader.load([])
    end

    it "should return matches" do
      dummy = ComplexDummy.create name: 'Baz', email: 'Bar'
      ComplexDummy.matcher.matches_for_term("Baz", cache: false).should ==
          [{'id' => dummy.id, 'term' => 'Baz', 'data' => {'email' => dummy.email}}]
    end

    it "should return properly formatted results from search" do
      dummy = ComplexDummy.create name: 'Baz', email: 'Bar'
      dummy2 = ComplexDummy.create name: 'Bazzy', email: 'Baz'
      ComplexDummy.search('Baz').sort_by {|h| h[:id]}.should ==
          [{id: dummy.id, value: 'Baz', label: 'term Baz for data Bar'},
           {id: dummy2.id, value: 'Bazzy', label: 'term Bazzy for data Baz'}].sort_by {|h| h[:id]}
    end
  end
end