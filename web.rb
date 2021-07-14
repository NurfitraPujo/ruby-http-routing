require 'sinatra'

get '/message' do
    "<h1 style=\"font-size:24px;\">Hello world</h1>"
end

get '/message/:name' do
    name = params[:name]
    color = params[:color] ? params[:color] : 'rebeccapurple'
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

items = ['ramen', 'sushi']

get '/items' do
    erb :items, locals: {
        items: items
    }
end

post '/items' do
    new_item = params[:new_item]
    items << new_item unless new_item == ""
    erb :items, locals: {
        items: items
    }
end