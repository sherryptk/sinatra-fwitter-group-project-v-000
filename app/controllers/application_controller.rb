require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  # HOME PAGE
  get '/' do

    erb :index
  end

  # CREATE TWEET
  get '/tweets/new' do
    if logged_in?
      erb :'/tweets/create_tweet'
    else
      redirect to '/login'
    end
  end

  post '/tweets' do
    if params[:content] == ""
      redirect to '/tweets/new'
    else
      @tweet = current_user.tweets.create(:content=> params["content"])
      id = @tweet.id

      @tweet.save
      redirect to "/tweets/#{id}"
    end
  end

  # SHOW TWEET
  get '/tweets/:id' do
    if logged_in?
      @tweet = Tweet.all.find(params[:id])
      erb :'/tweets/show_tweet'
    else
      redirect to '/login'
    end
  end

  # EDIT TWEET
  get '/tweets/:id/edit' do
    if logged_in?
      @tweet = Tweet.all.find(params[:id])
      erb :'tweets/edit_tweet'
    else
      redirect to '/login'
    end
  end

  patch '/tweets/:id' do
    @tweet = Tweet.all.find(params[:id])
    id = @tweet.id

    if params[:content] == ""
      redirect to "/tweets/#{id}/edit"
    else
      @tweet.content = params[:content]
      @tweet.save
      redirect to "/tweets/#{id}"
    end
  end

  # DELETE TWEET
  delete '/tweets/:id/delete' do
    @tweet = Tweet.all.find(params[:id])
    if logged_in? && current_user.id == @tweet.user.id
      @tweet.destroy
      redirect to "/tweets"
    else
      redirect to '/tweets'
    end
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :'users/show'
  end

  # SIGN UP
  get '/signup' do
    if logged_in?
      redirect to '/tweets'
    end
    erb :'/users/create_user'
  end

  post '/signup' do
    if params[:username] == '' || params[:email] == '' || params[:password] == ''
    redirect to '/signup'
    else
      @user = User.create(username: params["username"], email: params["email"], password: params["password"])
        session[:user_id] = @user.id
        redirect to '/tweets'
    end
  end

  get '/tweets' do
    if logged_in?
      @user = current_user
      erb :'/tweets/tweets'
    else redirect '/login'
    end
  end

  # LOG IN
  get '/login' do
    if logged_in?
      redirect to '/tweets'
    else
      erb :'/users/login'
    end
  end

  post '/login' do
    @user = User.find_by(username: params["username"])
    if @user && @user.authenticate(params[:password])
        session[:user_id] = @user.id
        redirect to '/tweets'
    else
        redirect "/login"
    end
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end
