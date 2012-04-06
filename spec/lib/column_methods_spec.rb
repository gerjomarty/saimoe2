require File.expand_path('../../spec_helper', __FILE__)

describe ColumnMethods do
  before :each do
    build_model :dummy do
      attr_accessible :name, :email
      string :name
      string :email
    end
  end

  describe :q_column do
    it "should quote a given String column name" do
      Dummy.q_column('foo').should == %Q{"dummies"."foo"}
    end

    it "should quote a given Symbol column name" do
      Dummy.q_column(:bar).should == %Q{"dummies"."bar"}
    end
  end

  describe :all_columns do
    it "should return all quoted columns" do
      Dummy.all_columns.should == %Q{"dummies"."id", "dummies"."name", "dummies"."email"}
    end
  end
end