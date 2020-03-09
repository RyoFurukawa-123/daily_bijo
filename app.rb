require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/cookies'
enable :sessions

get "/" do
    @title = "DailyBijo"
    return erb :index
end

# ログイン画面
get "/signin" do
    @title = "Signin"
    return erb :signin
end

post "/signin" do
    session[:user] = params[:name]
    redirect '/mypage'
end

# マイページ
get "/mypage" do
    @name = session[:user]
    return erb :mypage
end

# マイページ・ログアウト用
post "/mypage" do 
    session[:user] = nil
    redirect '/signin'
end
