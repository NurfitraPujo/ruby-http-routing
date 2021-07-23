require './model/category'

class CategoryController
  def create_new(category_data = {})
    raise ArgumentError if category_data.nil?

    category = Category.new(category_data)
    category.save
  end

  def find_all
    categories = Category.all

    renderer = ERB.new(File.read('./views/categories.erb'))
    renderer.result(binding)
  end

  def find_all_category_items(category_id)
    category = Category.query_category_items(category_id)

    renderer = ERB.new(File.read('./views/category_items.erb'))
    renderer.result(binding)
  end

  def creating_new_category
    renderer = ERB.new(File.read('./views/add_category.erb'))
    renderer.result(binding)
  end
end
