require 'collectionadapters/hash_sequel'
require 'sequel'

RSpec.describe CollectionAdapters::HashSequel do
  let(:db)      { Sequel.sqlite }

  before { 
     db.create_table(:test_models) {
       primary_key :id
       String :mykey, index: true, unique: true
       String :myvalue
     }
  }

  let(:adapter) { CollectionAdapters::HashSequel }
  let(:model)   { Sequel::Model(db[:test_models]) }
  let(:myhash)  { adapter.new(model: model, keycolumn: :mykey, valuecolumn: :myvalue) }

  describe "#new" do
    it "takes model:, keycolumn: and valuecolumn: as parameters" do
      expect(myhash).not_to be nil
    end
  end

  describe "#[]=" do
    it "Inserts or updates a value in the specified table at the specified key" do
      myhash["foobar"] = "baz"
      expect(model[mykey: "foobar"].myvalue).to eq "baz"
      myhash["foobar"] = 42
      expect(model[mykey: "foobar"].myvalue).to eq "42"
    end

    it "Returns the value" do
      expect(myhash["foobar"] = "baz").to eq "baz"
    end
  end

  describe "#delete" do
    it "Deletes the value in the specified table" do
      myhash["foobar"] = "baz"
      expect(model[mykey: "foobar"].myvalue).to eq "baz"
      myhash.delete("foobar")
      expect(model[mykey: "foobar"]).to eq nil
      expect(myhash["foobar"]).to eq nil
    end

    it "Returns the old value" do
      myhash["foobar"] = "old"
      expect(myhash.delete("foobar")).to eq "old"
    end

    it "Returns nil if deleting non-existent key" do
      expect(myhash.delete("foobar")).to eq nil
    end
  end
end
