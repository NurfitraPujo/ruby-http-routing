require './model/item'

class ItemController
  def create_new(item_data = {})
    raise ArgumentError if item_data.nil?

    item = Item.new(item_data)
    item.save
  end

  def find_all
    items = Item.all

    renderer = ERB.new(File.read('./views/items.erb'))
    renderer.result(binding)
  end

  def find_by_id(item_id)
    item = Item.where(column: 'items.id', value: item_id)[0]

    renderer = ERB.new(File.read('./views/item.erb'))
    renderer.result(binding)
  end

  def update(item_data = {})
    items = Item.update(item_data)

    renderer = ERB.new(File.read('./views/items.erb'))
    renderer.result(binding)
  end

  def delete(item_id)
    Item.delete(item_id)
  end
end
