require 'spec_helper'

class DummyMigration; end

describe ForeignKeyMigration do
  before :each do
    subject { DummyMigration.new }
    subject.extend ForeignKeyMigration
  end

  describe "#add_foreign_key" do
    it "should add a foreign key" do
      alter_text = 'ALTER TABLE dummies ADD CONSTRAINT fk_dummies_people FOREIGN KEY (person_id) REFERENCES people(id)'
      subject.expects(:execute).with(alter_text)
      subject.add_foreign_key :dummies, :person_id
    end

    it "should add a foreign key given a reference table" do
      alter_text = 'ALTER TABLE dummies ADD CONSTRAINT fk_dummies_people FOREIGN KEY (person_id) REFERENCES foo(id)'
      subject.expects(:execute).with(alter_text)
      subject.add_foreign_key :dummies, :person_id, reference_table: :foo
    end

    it "should add a named foreign key" do
      alter_text = 'ALTER TABLE dummies ADD CONSTRAINT my_special_name FOREIGN KEY (person_id) REFERENCES people(id)'
      subject.expects(:execute).with(alter_text)
      subject.add_foreign_key :dummies, :person_id, name: :my_special_name
    end
  end

  describe "#drop_foreign_key" do
    it "should drop the foreign key" do
      alter_text = 'ALTER TABLE dummies DROP CONSTRAINT fk_dummies_people'
      subject.expects(:execute).with(alter_text)
      subject.drop_foreign_key :dummies, :person_id
    end

    it "should drop the named foreign key" do
      alter_text = 'ALTER TABLE dummies DROP CONSTRAINT my_special_name'
      subject.expects(:execute).with(alter_text)
      subject.drop_foreign_key :dummies, :person_id, name: :my_special_name
    end

    it "should drop the foreign key on MySQL" do
      ActiveRecord::Base.connection.stubs(:adapter_name).returns('mysql2')
      alter_text = 'ALTER TABLE dummies DROP FOREIGN KEY fk_dummies_people'
      subject.expects(:execute).with(alter_text)
      subject.drop_foreign_key :dummies, :person_id
    end
  end
end