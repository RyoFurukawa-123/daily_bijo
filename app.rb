require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/cookies'
require 'pg'

enable :sessions

client = PG::connect(
    host: 'localhost', #今回はローカル環境なのでlocalhost
    user: 'furukawaryou', #ターミナルでwhoamiを実行し表示されたユーザー名
    password: '', #接続時のパスワード今回は設定しないので、空白
    dbname: "aabijo" #作成したデータベース名
    ) 


get "/" do
    @title = "DailyBijo"
    return erb :index
end

# ログイン画面
get "/login" do
    @title = "Login"
    redirect '/main' if session[:id]
    return erb :login
end

post '/login' do
    name = params[:name]
    email = params[:email]
    password = params[:password]

    @res = client.exec_params('select * from users where name = $1 and email = $2 and password = $3', [name, email, password]).first # @resにparamsで受け取ったname、email、passを元にusersテーブルからとってきて代入する

    redirect '/login' if @res.nil?  #@resがnilだと /loginにリダイレクト
    session[:user_id] = @res['id'].to_i  #@res['id'].to_iは@res['id']と取得されるデータが文字列なので整数に変換してsession[:user_id]に代入している。これでsessionに現在ログインしているuseが保持される。

    redirect '/main'
end
=begin
    post '/login' do
        session[:user] = params[:name]
        #login.erbファイルのフォームのinputタグのnameと一致する値をそれぞれ取得する
        email = params[:email]
        password = params[:password]
        #入力されたemailとpasswordがデータベースに登録されている情報と一致するか照合し、user変数へ代入する
        user = db.exec_params("select * from users where email = $1 and password = $2",[email, password]).first
        if user #もしユーザー情報が一致した場合
            session[:id] = user['id'] #セッションにユーザーIDを代入する
            session[:notice] = {class: "success", message: "ログインしました"} #ログイン成功時のフラッシュメッセージ
            redirect '/posts' #投稿一覧ページにリダイレクトする
        else #ユーザー情報が一致しなかった場合
            session[:notice] = {class: "danger", message: "メールアドレスかパスワードが間違っています"} #ログイン失敗時のフラッシュメッセージ
            redirect '/login' #ログインページへリダイレクトする
        end
    end
=end

# ログアウト処理
get '/logout' do
    session.clear #保持しているセッション情報を削除する
    session[:notice] = {class: "danger", message: "ログアウトしました"} #ログアウト時のフラッシュメッセージ
    redirect '/' #ルートパスへリダイレクトする
end


#サインアップ
get '/signup' do
    erb :signup
end

post '/signup' do

    name = params[:name]            #view側で送信されたnameを受け取る
    email = params[:email]          #view側で送信されたemailを受け取る
    password = params[:password]    #view側で送信されたpasswordを受け取る
    confirmation = params[:confirmation]  #view側で送信されたconfirmationを受け取る

    redirect '/signup' if password != confirmation #もしpasswordとconfirmationが違う時 /signupにリダイレクトされる。

    client.exec_params('insert into users(name,email,password) values($1,$2,$3)',[name,email,password])# usersテーブルに上で定義した変数(name,email,pass)の中身を入れる。

    redirect '/'   # '/' にリダイレクトされる

end

=begin
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
=end


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
