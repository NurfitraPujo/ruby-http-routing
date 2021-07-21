require 'sinatra'
require 'sinatra/reloader' if development?
require_relative './lib/items'

items_ins = Items.new

get '/message' do
  '<h1 style="font-size:24px;">Hello world</h1>'
end

get '/message/:name' do
  name = params[:name]
  color = params[:color] || 'rebeccapurple'
  erb :message, locals: {
    color: color,
    name: name
  }
end

get '/login' do
  erb :login
end

post '/login' do
  if params[:username] == 'admin' && params[:password] == 'admin'
    return 'Logged in'
  else
    erb :login
  end
end

get '/' do
  items = items_ins.get_all_items_with_categories
  erb :items, locals: {
    items: items
  }
end

get '/items' do
  items = items_ins.get_all_items_with_categories
  erb :items, locals: {
    items: items
  }
end

get '/item/:item_id' do
  item_id = params[:item_id]
  item = items_ins.get_item_by_id(item_id)
  erb :item, locals: {
    item: item
  }
end

post '/items' do
  nama = params[:nama]
  price = params[:price]
  new_item = {
    nama: nama,
    price: Integer(price)
  }
  items_ins.add_item_query(new_item)
  items = items_ins.get_all_items_with_categories
  erb :items, locals: {
    items: items
  }
end

get '/item/:item_id/edit' do
  item_id = params[:item_id]
  item = items_ins.get_item_by_id(item_id)
  erb :edit_item, locals: {
    item: item
  }
end

post '/item' do
  id = params[:id]
  nama = params[:nama]
  price = params[:price]
  new_item = {
    id: id,
    nama: nama,
    price: Integer(price)
  }
  edited_items = items_ins.edit_item(new_item)
  redirect '/items'
end
