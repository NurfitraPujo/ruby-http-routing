require_relative '../lib/db_connector'

class Category
  attr_accessor :id, :category

  def initialize(category_data = {})
    raise ArgumentError, 'Params not valid' unless category_will_created?(category_data)

    @id = category_data[:id]
    @category = category_data[:category]
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

  def self.query_categories
    db_client = DatabaseConnection.new
    db_client.query('SELECT id, category from categories')
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
