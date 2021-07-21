require_relative './lib/items'

items_ins = Items.new

#items = items_ins.get_all_items
items_with_categories = items_ins.get_all_items_with_categories
#items_lower_price = items_ins.get_all_items(20000)

#  def iterate_items(items)
#     items.each do |item|
#       puts item
#     end
#   end

# iterate_items(items)
# puts("\n")
# iterate_items(items_with_categories)
# puts("\n")
# iterate_items(items_lower_price)

puts items_with_categories