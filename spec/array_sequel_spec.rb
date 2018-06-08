require 'collectionadapters/array_sequel'
require 'sequel'

RSpec.describe CollectionAdapters::ArraySequel do
  let(:db)      { Sequel.sqlite }

  before { 
     db.create_table(:test_array) {
       primary_key :id
       String :data, index: true
     }

     db.create_table(:test_set) {
       primary_key :id
       String :data, index: true, unique: true
     }
  }

  let(:adapter)   { CollectionAdapters::ArraySequel }
  let(:arymodel)  { Sequel::Model(db[:test_array]) }
  let(:setmodel)  { Sequel::Model(db[:test_set]) }
  let(:myary)     { adapter.new(model: arymodel, column: :data) }
  let(:myset)     { adapter.new(model: setmodel, column: :data) }
  let(:revmodel)  { arymodel.reverse(:id) }
  let(:myary_rev) { adapter.new(model: revmodel, column: :data) }

  describe "#new" do
    it "takes model:, and column: as parameters" do
      expect(myary).not_to be nil
    end
  end

  describe "#<<" do
    it "It inserts values into the table" do
      myary << "foo"
      myary << "bar"
      expect(arymodel[data: "foo"].data).to eq "foo"
      expect(arymodel[data: "bar"].data).to eq "bar"
    end

    it "When used as an Array (without a unique index), duplicate values may be added" do
      myary << "foo"
      myary << "foo"
      expect(arymodel.where(data: "foo").count).to eq 2
    end

    it "When used as a Set (with a unique index), duplicate values are ignored" do
      myset << "foo"
      myset << "foo"
      expect(setmodel.where(data: "foo").count).to eq 1
    end
  end

  #
  # FIXME: Currently we're not guaranteeing FIFO order
  #
  describe "#shift" do
    it "Removes an item, and returns it" do
      myary << "foo"
      myary << "bar"
      expect(arymodel.count).to eq 2
      r1 = myary.shift
      expect(arymodel.count).to eq 1
      expect(r1 == "foo" || r1 == "bar").to be true
      r2 = myary.shift
      expect(arymodel.count).to eq 0
      expect(r2 == "foo" || r2 == "bar").to be true
      expect(r1 != r2).to be true
    end

    it "Returns items according to dataset order if you create the object with a dataset instead of a model" do
      myary_rev << "foo"
      myary_rev << "bar"
      expect(arymodel.first(data: "foo").pk < arymodel.first(data: "bar").pk).to be true
      expect(myary_rev.shift).to eq "bar"
      expect(myary_rev.shift).to eq "foo"
    end
  end
end
