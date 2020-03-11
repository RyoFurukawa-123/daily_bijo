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
get "/login" do
    @title = "Login"
    return erb :login
end

post "/login" do
    session[:user] = params[:name]
    redirect '/main'
end

#サインアップ
get '/signup' do
    erb :signup
end

post '/signup' do
    #signup.erbのフォームのinputタグのnameと一致する値をそれぞれ取得する
    name = params[:name]
    email = params[:email]
    password = params[:password]
    #入力された値をデータベースに保存する。PostgreSQLではreturningを書くことで実行したSQLのデータを返してくれる
    user = db.exec_params("insert into users(name, email, password) values($1, $2, $3) returning id",[name, email, password]).first
    session[:id] = user['id'] #サインアップと同時にログイン処理を行う
    session[:notice] = {class: "success", message: "登録が完了しました"} #登録完了時のフラッシュメッセージ
    redirect '/main' #メインページにリダイレクトする
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
    redirect '/login'
end

#コレクション
get "/collection" do
    return erb :collection
end
