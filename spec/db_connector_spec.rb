require './spec/test_helper'
require './lib/db_connector'

describe DatabaseConnection do
  before(:all) do
    @db_client = DatabaseConnection.instance
  end

  context 'it should use test databases' do
    it 'should return zero item' do
      items = @db_client.query('SELECT * FROM items')

      expect(items.count).to eq(0)
    end
  end
end
