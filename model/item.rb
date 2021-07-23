require_relative '../lib/db_connector'
require_relative './category'

class Item
  attr_accessor :id, :nama, :price, :category

  def initialize(item_data = {})
    raise ArgumentError, 'Params not valid' unless item_will_created?(item_data)

    @id = item_data[:id]
    @nama = item_data[:nama]
    @price = item_data[:price]
    unless item_data[:category_id].nil?
      @category = Category.new(id: item_data[:category_id],
                               category: item_data[:category])
    end
  end

  def item_will_created?(item_data)
    return false if item_data.nil?
    return false if item_data[:nama].nil?
    return false if item_data[:price].nil?

    true
  end

  def valid?
    return false if @nama.nil?
    return false if @price.nil?

    true
  end

  def save
    return false unless valid?

    db_client = DatabaseConnection.new
    db_client.transaction do
      db_client.query("INSERT INTO items(nama, price) VALUES ('#{@nama}', #{@price})")
      unless @category.nil?
        raw_new_item = db_client.query('SELECT * FROM items ORDER BY items.id DESC LIMIT 1')
        new_item = self.class.parse_raw(raw_new_item)[0]
        db_client.query("INSERT INTO item_categories VALUES ('#{new_item.id}', #{@category.id})")
      end
    end
  end

  def to_s
    "#{@id} #{@nama} #{@price} #{@category}"
  end

  def self.item_with_categories_query(min_price = 0)
    db_client = DatabaseConnection.new
    db_client.query("SELECT items.id, items.nama, items.price as price, c.id as category_id, c.category
        from items
        left join item_categories ic on items.id = ic.item_id
        left join categories c on ic.category_id = c.id
        #{min_price.zero? ? '' : "WHERE items.id = #{min_price}"}
        order by items.id")
  end

  def self.items_where_query(column, value, operation)
    operation = '=' if operation.nil?

    db_client = DatabaseConnection.new
    db_client.query("SELECT items.id, items.nama, items.price as price, c.id as category_id, c.category
        from items
        left join item_categories ic on items.id = ic.item_id
        left join categories c on ic.category_id = c.id
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

  def self.add_item_category_query(db_client, item_category_data = {})
    raise ArgumentError if item_category_data.nil?

    # db_client = DatabaseConnection.new
    db_client.query("INSERT INTO item_categories
        VALUES (#{item_category_data[:item_id]}, #{item_category_data[:category_id]})
      ")
  end

  def self.update_item_category_query(db_client, item_category_data = {})
    raise ArgumentError if item_category_data.nil?

    # db_client = DatabaseConnection.new
    db_client.query("UPDATE item_categories
        SET
          category_id = '#{item_category_data[:category_id]}'
        WHERE
          item_id = #{item_category_data[:item_id]}
      ")
  end

  def self.update_item_transaction_query(item_data = {})
    raise ArgumentError if item_data.nil?

    db_client = DatabaseConnection.new
    db_client.transaction do
      update_item_query(db_client, item_data)
      unless item_data[:category_id].nil?
        item_has_category = item_has_category_query(db_client, item_data[:id])
        if item_has_category
          update_item_category_query(db_client, item_id: item_data[:id], category_id: item_data[:category_id])
        else
          add_item_category_query(db_client, item_id: item_data[:id], category_id: item_data[:category_id])
        end
      end
    end
  end

  def self.delete_item_query(item_id)
    return false if item_id.nil?

    db_client = DatabaseConnection.new
    db_client.query("DELETE from items
        WHERE items.id = #{item_id}
      ")
  end

  def self.parse_raw(raw_data)
    items = []
    raw_data.each do |data|
      item = new(data)
      items << item
    end
    items
  end

  def self.all(min_price = 0)
    raw_data = item_with_categories_query(min_price)
    parse_raw(raw_data)
  end

  def self.where(params = {})
    raw_data = if params.nil?
                 item_with_categories_query
               elsif params[:column].nil? || params[:value].nil?
                 item_with_categories_query
               else
                 items_where_query(params[:column], params[:value], params[:operation])
               end
    parse_raw(raw_data)
  end

  def self.delete(item_id)
    delete_item_query(item_id)
  end

  def self.update(item_data = {})
    update_item_transaction_query(item_data)
    where(column: 'items.id', value: item_data[:id])
  end

  private_class_method :item_with_categories_query, :items_where_query, :delete_item_query, :update_item_query,
                       :update_item_transaction_query, :update_item_query, :item_has_category_query,
                       :update_item_category_query, :add_item_category_query
end
