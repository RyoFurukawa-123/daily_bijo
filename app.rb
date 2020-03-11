require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/cookies'

enable :sessions

def db
    PG::connect(
    host: 'localhost', #今回はローカル環境なのでlocalhost
    user: 'furukawaryou', #ターミナルでwhoamiを実行し表示されたユーザー名
    password: '', #接続時のパスワード今回は設定しないので、空白
    dbname: 'bijoapp' #作成したデータベース名
    ) 
end

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
    redirect '/main'
end

# メイン
get "/main" do
    @name = session[:user]
    return erb :main
end

#マイページ
get "/mypage" do

    return erb :mypage
end

# マイページ・ログアウト用
post "/mypage" do 
    session[:user] = nil
    redirect '/signin'
end

#コレクション
get "/collection" do
    return erb :collection
end
