require './model/item'

class ItemController
  def create_new(item_data = {})
    raise ArgumentError if item_data.nil?

    item_categories = []
    unless item_data[:categories].empty?
      item_data[:categories].each do |id|
        category = { id: id }
        item_categories << category
      end
    end

    item = Item.new(id: item_data[:id], nama: item_data[:nama], price: item_data[:price], categories: item_categories)
    item.save
  end

  def find_all
    Item.all
  end

  def all_items
    items = find_all
    renderer = ERB.new(File.read('./views/items.erb'))
    renderer.result(binding)
  end

  def find_by_id(item_id)
    Item.where(column: 'items.id', value: item_id)[0]
  end

  def item_details(item_id)
    item = find_by_id(item_id)
    renderer = ERB.new(File.read('./views/item.erb'))
    renderer.result(binding)
  end

  def update(item_data = {})
    Item.update(item_data)
  end

  def delete(item_id)
    Item.delete(item_id)
  end
end
