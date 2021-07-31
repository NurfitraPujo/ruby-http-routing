require './spec/test_helper'
require './model/item'

describe Item do
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
      
  end
end
