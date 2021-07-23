require 'sinatra'
require 'sinatra/reloader' if development?
require_relative './controller/item_controller'
require_relative './controller/category_controller'

get '/' do
  redirect '/items'
end

get '/items' do
  items_co = ItemController.new
  # category_co = CategoryController.new
  # categories = category_co.find_all
  items_co.find_all
end

get '/items/new' do
  category_co = CategoryController.new
  categories = category_co.find_all
  erb :add_item, locals: {
    categories: categories
  }
end

get '/item/:item_id' do
  items_co = ItemController.new
  items_co.find_by_id(params[:item_id])
end

post '/items' do
  items_co = ItemController.new
  items_co.create_new(nama: params[:nama], price: params[:price], category_id: params[:category])
  redirect '/items'
end

get '/item/:item_id/edit' do
  item_id = params[:item_id]
  items = Item.where(column: 'items.id', value: item_id)
  categories = Category.all
  erb :edit_item, locals: {
    item: items[0],
    categories: categories
  }
end

post '/item' do
  items_co = ItemController.new
  items_co.update(id: params[:id], nama: params[:nama], price: Integer(params[:price]), category_id: params[:category])
  redirect '/items'
end

get '/item/:item_id/delete' do
  items_co = ItemController.new
  items_co.delete(params[:item_id])
  redirect '/items'
end

get '/categories/new' do
  category_co = CategoryController.new
  category_co.creating_new_category
end

post '/categories' do
  category_co = CategoryController.new
  category_co.create_new(category: params[:category])
  redirect '/items'
end

get '/categories' do
  category_co = CategoryController.new
  category_co.find_all
end

get '/category/:category_id' do
  category_co = CategoryController.new
  category_co.find_all_category_items(params[:category_id])
end

# get '/item/:item_id/delete' do
#   item_id = params[:item_id]
#   items_ins.delete_item(item_id)
#   redirect '/items'
# end
