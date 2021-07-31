require './spec/test_helper'
require './lib/db_connector'
require './model/item'

describe Item do
  before(:all) do
    @db_client = DatabaseConnection.instance
  end

  describe '#valid?' do
    context 'it should return true' do
      it 'should return true given right argument' do
        item = Item.new(id: 1, nama: 'test', price: 2000)
        expect(item.valid?).to eq(true)
      end

      it 'should return false given wrong number of arguments' do
        item = Item.new(id: 1, nama: 'test', price: nil)
        expect(item.valid?).to eq(false)
      end
    end
  end

  describe '#save' do
    before(:each) do
      @db_client.query('DELETE FROM items')
    end

    after(:all) do
      @db_client.query('DELETE FROM items')
    end

    context 'it should add item into database if item is valid' do
      it 'should return 1 if item is valid' do
        item = Item.new(id: 1, nama: 'test', price: 2000)
        item.save
        items = Item.all
        expect(items.size).to eq(1)
      end

      it 'should return 0 if item is not valid' do
        item = Item.new(id: 1, nama: 'test', price: nil)
        item.save
        items = Item.all
        expect(items.size).to eq(0)
      end
    end
  end
end
