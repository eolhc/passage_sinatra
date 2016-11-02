require 'active_record'
require 'sinatra'
require 'sinatra/reloader'

require_relative 'db_config'
require_relative 'models/follower'
require_relative 'models/image'
require_relative 'models/location'
require_relative 'models/route'
require_relative 'models/user'
require_relative 'models/vote'
require_relative 'models/step'

require 'pry'

enable :sessions

get '/' do
  #display three random location's most popular route's img
  @randLocations = Location.order("RANDOM()")

  erb :index
end

#create new location request
#this should link from a search results page
get '/locations/new' do
  @locations = Location.all

  erb :location_new
end

#save new location entry
post '/locations' do
  @new_loc = Location.new
  @new_loc.name = params[:location]

  @new_loc.user_id = User.all.find_by(username: "#{params[:username]}").id

  if @new_loc.save
    redirect to '/'
  else erb :location_new
  end
#need new and save here

end
#show locations page
get '/locations/:locationid' do
  @location = Location.find(params[:locationid])
  @name = @location.name
  @routes = @location.routes

  erb :location
end

#create new route entry
#this should link from the unique location page
get "/locations/:locationid/new" do

  erb :route_new
end

#post new route
post '/locations/:locationid' do
  @new_route = Route.new
  @new_route.title = params[:title]
  @new_route.location_id = params[:locationid]
  @new_route.date_authored = Time.now.strftime("%Y-%m-%d")
  @new_route.description = params[:description]
  @new_route.author_id = User.all.find_by(username: "#{params[:username]}").id
  @new_route.img = params[:img]
  # @new_route.votes = 0

  if @new_route.save
    redirect to "/locations/#{@new_route.location_id}/#{@new_route.id}"
  else erb :route_new
  end
end

#show routes page
get '/locations/:locationid/:routeid' do
  @route = Route.where('id = ? AND location_id = ?', params[:routeid], params[:locationid])[0]
  @date = @route.date_authored
  @title = @route.title
  @description = @route.description
  @votes = @route.votes
  @author_id = @route.author_id

  erb :route
end

#anything with ID should be below anything with word

#show edit route form
get '/locations/:locationid/:routeid/edit' do
  @route = Route.where('id = ? AND location_id = ?', params[:routeid], params[:locationid])[0]

  erb :route_edit
end

#update route
post '/locations/:locationid/:routeid' do
  @routeid = params[:routeid]
  @locid = params[:locationid]
  @route = Route.where('id = ? AND location_id = ?', @routeid, @locid)[0]

  @route.update(title: params[:title], date_authored: Time.now.strftime("%Y-%m-%d"), description: params[:description], img: params[:img])

  redirect to "/locations/#{@locid}/#{@routeid}"
end

#delete route
post '/locations/:locationid/:routeid/delete' do
  @route = Route.where('id = ? AND location_id = ?', params[:routeid], params[:locationid])[0]
  @route.destroy

  redirect to '/locations/:locationid'
end

get '/session/new' do

  erb :session_new
end

post '/session' do
  user = User.find_by(username: params[:username])

  if user && user.authenticate(params[:password])
    #u are fine, lemme create a session for u
    session[:user_id] = user.id

    redirect to '/'
  else #whoaare you
    erb :session_new
  end
end

post '/register' do
  user = User.new
  user.email = params[:email]
  user.username = params[:username]
  user.password = params[:password]
  if User.find_by(username: params[:username]) != nil
    @msg = "username already taken pls pick another one"
    erb :session_new
  elsif User.find_by(email: params[:email]) != nil
    @msg = "email already in use"
    erb :session_new
  else user.save
      redirect to '/session/new'
  end
end

delete '/session' do
  session[:user_id] = nil
  #remove the session
  redirect to '/session/new'
end
