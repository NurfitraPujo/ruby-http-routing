require_relative './db_connector'
require_relative './item'
require_relative './category'

class Items
  def initialize(db_con = DatabaseConnection.new)
    @db_client = db_con.db_client
  end

  def query_all_items(price = 0)
    return @db_client.query("SELECT * from items where price < #{price} order by id") unless price.zero?

    @db_client.query('SELECT * from items order by id')
  end

  def get_categories
    @db_client.query('SELECT * from categories order by id')
  end

  def query_items_with_categories(price = 0)
    unless price.zero?
      return @db_client.query('SELECT items.id, items.nama, FORMAT(items.price, 2) as price, c.id as category_id, c.category
          from items
          left join item_categories ic on items.id = ic.item_id
          join categories c on ic.category_id = c.id
          order by items.id')
    end
    @db_client.query('SELECT items.id, items.nama, FORMAT(items.price, 2) as price, c.id as category_id, c.category
        from items
        left join item_categories ic on items.id = ic.item_id
        left join categories c on ic.category_id = c.id
        order by items.id')
  end

  def query_item_by_id(item_id)
    @db_client.query("SELECT items.id, items.nama, items.price, c.category
        from items
        left join item_categories ic on items.id = ic.item_id
        left join categories c on ic.category_id = c.id
        where items.id = #{item_id}")
  end

  def add_item_query(item_data)
    @db_client.query("INSERT into items(nama, price)
    VALUES ('#{item_data[:nama]}', #{item_data[:price]})")
  rescue Mysql2::Error => e
    puts e
  end

  def update_item_query(item_data)
    @db_client.query("UPDATE items
        SET
          items.nama = '#{item_data.nama}',
          items.price = #{item_data.price}
        WHERE
          items.id = #{item_data.id}
      ")
  end

  def item_has_category_query(item_id)
    @db_client.query("SELECT * from item_categories
        WHERE item_id = #{item_id}
      ")
  end

  def add_item_category(item_data)
    @db_client.query("INSERT into item_categories
        VALUES (#{item_data.id}, #{item_data.category.id})
      ")
  end

  def update_item_category_query(item_id, category_id)
    @db_client.query("UPDATE item_categories
        SET
          caegory_id = #{category_id}
        WHERE
          items.id = #{item_id}
      ")
  end

  def get_all_items(price = 0)
    raw_data = query_items_with_categories(price)
    items = []
    raw_data.each do |data|
      item = Item.new(data['id'], data['nama'], data['price'])
      items << item
    end
    items
  end

  def get_all_items_with_categories(price = 0)
    raw_data = query_items_with_categories(price)
    items = []
    raw_data.each do |data|
      category = Category.new(data['category_id'], data['category'])
      item = Item.new(data['id'], data['nama'], data['price'], category.category)
      items << item
    end
    items
  end

  def get_item_by_id(item_id)
    return nil if item_id.nil?

    item = nil
    raw_data = query_item_by_id(item_id)
    raw_data.each do |data|
      category = Category.new(data['category_id'], data['category'])
      item = Item.new(data['id'], data['nama'], data['price'], category.category)
    end
    item
  end

  def edit_item(item_data)
    item = Item.new(item_data[:id], item_data[:nama], item_data[:price])
    update_item_query(item)
    get_all_items_with_categories
  end
end
