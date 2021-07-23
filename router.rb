require 'sinatra'
require 'sinatra/reloader' if development?
require_relative './model/item'
require_relative './model/category'

get '/' do
  items = Item.all
  erb :items, locals: {
    items: items
  }
end

get '/items' do
  items = Item.all
  categories = Category.all
  erb :items, locals: {
    items: items,
    categories: categories
  }
end

get '/item/:item_id' do
  item_id = params[:item_id]
  items = Item.where(column: 'items.id', value: item_id)
  erb :item, locals: {
    item: items[0]
  }
end

post '/items' do
  nama = params[:nama]
  price = params[:price]
  category_id = params[:category]
  new_item = {
    nama: nama,
    price: Integer(price),
    category_id: category_id
  }
  item = Item.new(new_item)
  item.save
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
  id = params[:id]
  nama = params[:nama]
  price = params[:price]
  category_id = params[:category]
  new_item = {
    id: id,
    nama: nama,
    price: Integer(price),
    category_id: category_id
  }
  Item.update(new_item)
  redirect '/items'
end

get '/item/:item_id/delete' do
  item_id = params[:item_id]
  Item.delete(item_id)
  redirect '/items'
end

# get '/item/:item_id/delete' do
#   item_id = params[:item_id]
#   items_ins.delete_item(item_id)
#   redirect '/items'
# end
