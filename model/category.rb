require_relative '../lib/db_connector'

class Category
  attr_accessor :id, :category, :items

  def initialize(category_data = {})
    raise ArgumentError, 'Params not valid' unless category_will_created?(category_data)

    @id = category_data[:id]
    @category = category_data[:category]
    @items = []
  end

  def category_will_created?(category_data)
    return false if category_data.nil?

    # return false if category_data[:category].nil?

    true
  end

  def valid?
    return false if category_data[:category].nil?

    true
  end

  def to_s
    @category.to_s
  end

  def save
    return false unless valid?

    db_client = DatabaseConnection.new
    db_client.query("INSERT INTO categories(category) VALUES ('#{category}')")
  end

  def add_item(item_data = {})
    item = Item.new(id: item_data[:id], nama: item_data[:nama], price: item_data[:price])
    @items << item
  end

  def self.query_categories
    db_client = DatabaseConnection.new
    db_client.query('SELECT id, category from categories')
  end

  def self.query_category_items(category_id)
    db_client = DatabaseConnection.new
    raw_categories = db_client.query("SELECT id, category from categories WHERE id = #{category_id}")
    categories = parse_raw(raw_categories)
    categories.each do |category|
      raw_category_items = db_client.query("SELECT item_id as id, items.price, items.nama , category_id
        from item_categories
        JOIN items on item_id = items.id
        WHERE category_id = #{category.id}
        ")
      raw_category_items.each do |category_item|
        category.add_item(id: category_item[:id], nama: category_item[:nama], price: category_item[:price])
      end
    end
    categories[0]
  end

  def self.parse_raw(raw_data)
    categories = []
    raw_data.each do |data|
      category = new(data)
      categories << category
    end
    categories
  end

  def self.all
    raw_data = query_categories
    parse_raw(raw_data)
  end
end
