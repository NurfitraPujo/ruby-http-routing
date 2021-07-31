require_relative '../lib/db_connector'
require_relative './category'

class Item
  attr_accessor :id, :nama, :price, :categories

  def initialize(item_data = {})
    @id = item_data[:id]
    @nama = item_data[:nama]
    @price = item_data[:price]
    @categories = []
    unless item_data[:categories].nil?
      item_data[:categories].each do |raw_data|
        item_category = Category.new(raw_data)
        @categories << item_category
      end
    end
  end

  def valid?
    return false if @nama.nil?
    return false if @price.nil?

    true
  end

  def save
    return false unless valid?

    db_client = DatabaseConnection.instance
    db_client.transaction do
      db_client.query("INSERT INTO items(nama, price) VALUES ('#{@nama}', #{@price})")
      unless @categories.empty?
        raw_new_item = db_client.query('SELECT * FROM items ORDER BY items.id DESC LIMIT 1')
        new_item = self.class.parse_raw(raw_new_item)[0]
        item_categories_values = generate_insert_category_values(new_item.id)
        db_client.query("INSERT INTO item_categories VALUES #{item_categories_values}")
      end
    end
  end

  def to_s
    "#{@id} #{@nama} #{@price} #{@category}"
  end

  def hash
    @id.hash ^ @nama.hash ^ @price.hash ^ @categories.hash
  end

  def ==(other)
    hash == other.hash
  end

  def generate_insert_category_values(item_id)
    values = ''
    @categories.each do |category|
      value = "(#{item_id}, #{category.id})"
      value += ', ' unless category.equal? categories.last
      values << value
    end
    values
  end

  def self.items_query
    db_client = DatabaseConnection.instance
    db_client.query("SELECT items.id, items.nama, items.price as price
        from items
        order by items.id")
  end

  def self.item_categories_query(item_id)
    db_client = DatabaseConnection.instance
    db_client.query("SELECT ic.category_id as id, categories.category
        from item_categories ic
        join categories on ic.category_id = categories.id
        where ic.item_id = #{item_id}
        order by ic.category_id")
  end

  def self.items_where_query(column, value, operation = nil)
    operation = '=' if operation.nil?

    db_client = DatabaseConnection.instance
    db_client.query("SELECT items.id, items.nama, items.price as price
        from items
        WHERE #{column}" + operation + "#{value}
        order by items.id")
  end

  def self.update_item_query(db_client, item_data = {})
    raise ArgumentError if item_data.nil? || item_data[:id].nil?

    # db_client = DatabaseConnection.new
    db_client.query("UPDATE items
        SET
          items.nama = '#{item_data[:nama]}',
          items.price = #{item_data[:price]}
        WHERE
          items.id = #{item_data[:id]}
      ")
  end

  def self.item_has_category_query(db_client, item_id)
    raise ArgumentError if item_id.nil?

    item_has_category = false
    raw_data = db_client.query("SELECT item_id FROM item_categories WHERE item_id = #{item_id}")
    item_has_category = true unless raw_data.count.zero?
    item_has_category
  end

  def self.generate_insert_category_values(item_id, categories)
    values = ''
    categories.each do |category|
      value = "(#{item_id}, #{category})"
      value += ', ' unless category.equal? categories.last
      values << value
    end
    values
  end

  def self.add_item_category_query(db_client, item_category_data = [])
    raise ArgumentError if item_category_data.nil?

    # db_client = DatabaseConnection.new
    item_categories_values = generate_insert_category_values(item_category_data[:item_id],
                                                             item_category_data[:categories])
    db_client.query("INSERT INTO item_categories
        VALUES #{item_categories_values}
      ")
  end

  def self.delete_previous_item_categories(db_client, item_id)
    raise ArgumentError if item_id.nil?

    db_client.query("DELETE FROM item_categories
        WHERE
          item_id = #{item_id}
      ")
  end

  def self.update_item_transaction_query(item_data = {})
    raise ArgumentError if item_data.nil?

    db_client = DatabaseConnection.instance
    db_client.transaction do
      update_item_query(db_client, item_data)
      unless item_data[:categories].nil?
        item_has_category = item_has_category_query(db_client, item_data[:id])
        delete_previous_item_categories(db_client, item_data[:id]) if item_has_category
        add_item_category_query(db_client, item_id: item_data[:id], categories: item_data[:categories])
      end
    end
  end

  def self.delete_item_query(item_id)
    return false if item_id.nil?

    db_client = DatabaseConnection.instance
    db_client.transaction do
      db_client.query("DELETE FROM item_categories WHERE item_id = #{item_id}")
      db_client.query("DELETE FROM items WHERE id = #{item_id}")
    end
  end

  def self.parse_item_categories(raw_item_categories)
    item_categories = []
    raw_item_categories.each do |raw_data|
      item_categories << raw_data
    end
    item_categories
  end

  def self.parse_raw(raw_data)
    items = []
    raw_data.each do |data|
      raw_item_categories = item_categories_query(data[:id])
      item_categories = parse_item_categories(raw_item_categories)
      item = new(id: data[:id], nama: data[:nama], price: data[:price], categories: item_categories)
      items << item
    end
    items
  end

  def self.all
    raw_items_data = items_query
    parse_raw(raw_items_data)
  end

  def self.where(params = {})
    raise ArgumentError if params[:column].nil? || params[:value].nil?

    raw_items_data = items_where_query(params[:column], params[:value], params[:operation])
    parse_raw(raw_items_data)
  end

  def self.delete(item_id)
    delete_item_query(item_id)
  end

  def self.update(item_data = {})
    update_item_transaction_query(item_data)
    where(column: 'items.id', value: item_data[:id])
  end

  private_class_method :items_where_query, :delete_item_query, :update_item_query,
                       :update_item_transaction_query, :update_item_query, :item_has_category_query,
                       :add_item_category_query
end
