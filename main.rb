require 'sinatra'
require 'sinatra/reloader' if development?
require "sinatra/contrib"
require_relative './controller/item_controller'
require_relative './controller/category_controller'

config_file '../config/config.yml'

get '/' do
  redirect '/items'
end

get '/items' do
  items_co = ItemController.new
  # category_co = CategoryController.new
  # categories = category_co.find_all
  items_co.all_items
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
  items_co.item_details(params[:item_id])
end

post '/items' do
  items_co = ItemController.new
  items_co.create_new(nama: params[:nama], price: params[:price], categories: params[:categories])
  redirect '/items'
end

get '/item/:item_id/edit' do
  items_co = ItemController.new
  item = items_co.find_by_id(params[:item_id])
  category_co = CategoryController.new
  categories = category_co.find_all
  item_categories_id = item.categories.map(&:id)
  erb :edit_item, locals: {
    item: item,
    categories: categories,
    item_categories_id: item_categories_id
  }
end

post '/item' do
  items_co = ItemController.new
  items_co.update(id: params[:id], nama: params[:nama], price: Integer(params[:price]), categories: params[:categories])
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
  redirect '/categories'
end

get '/categories' do
  category_co = CategoryController.new
  category_co.show_all_categories
end

get '/category/:category_id' do
  category_co = CategoryController.new
  category_co.show_category_items(params[:category_id])
end

get '/category/:category_id/delete' do
  category_co = CategoryController.new
  category_co.delete(params[:category_id])
  redirect '/categories'
end

get '/category/:category_id/edit' do
  category_co = CategoryController.new
  category = category_co.find_by_id(params[:category_id])

  erb :edit_category, locals: {
    category: category
  }
end

post '/category' do
  category_co = CategoryController.new
  category_co.update(id: params[:id], category: params[:category])
  redirect '/categories'
end
