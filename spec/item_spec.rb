require './spec/test_helper'
require './lib/db_connector'
require './model/item'

describe Item do
  before(:all) do
    @db_client = DatabaseConnection.instance
  end

  describe '#valid?' do
    context 'when item is validated' do
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
      @db_client.query('ALTER TABLE items AUTO_INCREMENT = 0')
    end

    context 'when item is saved to persistence' do
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

  describe '.all' do
    before(:each) do
      @db_client.query('DELETE FROM items')
    end

    after(:each) do
      @db_client.query('DELETE FROM items')
      @db_client.query('ALTER TABLE items AUTO_INCREMENT = 0')
    end

    context 'when called should return items persistence records' do
      it 'should return 0 when items persistence doesnt have records' do
        items = Item.all
        expect(items.size).to eq(0)
      end

      it 'should return item with expected structure when items persistence have records' do
        item = Item.new(id: 1, nama: 'test', price: 2000)
        item.save

        items = Item.all
        expect(items[0]).to eq(item)
      end

      it 'should return the same item counts as records counts in items persistence' do
        item = Item.new(id: 1, nama: 'test', price: 2000)
        item.save

        item2 = Item.new(id: 2, nama: 'test', price: 2000)
        item2.save

        items = Item.all
        expect(items.size).to eq(2)
      end
    end
  end

  describe '.where' do
    before(:each) do
      @db_client.query('DELETE FROM items')
      @db_client.query('ALTER TABLE items AUTO_INCREMENT = 0')
    end

    after(:all) do
      @db_client.query('DELETE FROM items')
      @db_client.query('ALTER TABLE items AUTO_INCREMENT = 0')
    end

    context 'when item_id supplied' do
      it 'should return item with id that equals to given item_id' do
        item = Item.new(id: 1, nama: 'test', price: 2000)
        item.save

        item_db = Item.where(column: 'id', value: item.id)[0]
        expect(item_db).to eq(item)
      end

      it 'should return nil when item not found' do
        item_db = Item.where(column: 'id', value: 2)[0]
        expect(item_db).to be_nil
      end
    end

    context 'when item_id is not supplied' do
      it 'should throw ArgumentError' do
        expect { Item.where(column: 'id', value: nil)[0] }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.update' do
    before(:each) do
      @db_client.query('DELETE FROM items')
      item = Item.new(id: 1, nama: 'test', price: 2000)
      item.save
    end

    after(:all) do
      @db_client.query('DELETE FROM items')
      @db_client.query('ALTER TABLE items AUTO_INCREMENT = 0')
    end

    context 'when item_data is given' do
      it 'should update referenced item if argument is valid' do
        item_data = {
          id: 1,
          nama: 'test_update'
        }
        Item.update(item_data)
        item = Item.where(column: 'id', value: 1)[0]
        expect(item.nama).to eq(item_data[:nama])
      end
    end
  end
end
