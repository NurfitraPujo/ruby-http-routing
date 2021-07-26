require './model/category'

class CategoryController
  def create_new(category_data = {})
    raise ArgumentError if category_data.nil?

    category = Category.new(category_data)
    category.save
  end

  def find_all
    Category.all
  end

  def find_by_id(category_id)
    Category.where(category_id)[0]
  end

  def show_all_categories
    categories = find_all
    renderer = ERB.new(File.read('./views/categories.erb'))
    renderer.result(binding)
  end

  def find_all_category_items(category_id)
    Category.query_category_items(category_id)
  end

  def show_category_items(category_id)
    category = find_all_category_items(category_id)

    renderer = ERB.new(File.read('./views/category_items.erb'))
    renderer.result(binding)
  end

  def creating_new_category
    renderer = ERB.new(File.read('./views/add_category.erb'))
    renderer.result(binding)
  end

  def update(category_data = {})
    Category.update(category_data)
  end

  def delete(category_id)
    Category.delete(category_id)
  end
end
