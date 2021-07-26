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

    db_client = DatabaseConnection.instance
    db_client.query("INSERT INTO categories(category) VALUES ('#{category}')")
  end

  def add_item(item_data = {})
    item = Item.new(id: item_data[:id], nama: item_data[:nama], price: item_data[:price])
    @items << item
  end

  def self.query_categories(category_id = nil)
    where_query = ''
    where_query = "WHERE id = #{category_id}" unless category_id.nil?

    db_client = DatabaseConnection.instance
    db_client.query("SELECT id, category from categories
        #{where_query}
    ")
  end

  def self.query_category_items(category_id)
    db_client = DatabaseConnection.instance
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

  def self.delete_query(category_id)
    return false if category_id.nil?

    db_client = DatabaseConnection.instance
    db_client.transaction do
      db_client.query("DELETE FROM item_categories WHERE category_id = #{category_id}")
      db_client.query("DELETE FROM categories WHERE id = #{category_id}")
    end
  end

  def self.delete(category_id)
    delete_query(category_id)
  end

  def self.update(category_data = {})
    raise ArgumentError if category_data.nil? || category_data[:id].nil? || category_data[:category].nil?

    db_client = DatabaseConnection.instance
    db_client.query("UPDATE categories
        SET
          categories.category = '#{category_data[:category]}'
        WHERE
          categories.id = #{category_data[:id]}
      ")
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

  def self.where(category_id)
    raw_data = query_categories(category_id)
    parse_raw(raw_data)
  end
end
