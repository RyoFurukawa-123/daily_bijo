require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/cookies'
require 'pg'
require 'pry' #デバッグの際に使用するgem
require "fileutils" 

# http://localhost:4567/

enable :sessions

client = PG::connect(
    host: 'localhost', #今回はローカル環境なのでlocalhost
    user: 'furukawaryou', #ターミナルでwhoamiを実行し表示されたユーザー名
    password: '', #接続時のパスワード今回は設定しないので、空白
    dbname: "aabijo" #作成したデータベース名
    ) 

    def check_login
        redirect '/login' unless session[:user_id]
    end


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
    session[:user] = params[:name]

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
    redirect '/bye' #ルートパスへリダイレクトする
end

# いってらっしゃい
get '/bye' do
    return erb :bye
end



#サインアップ
get '/signup' do
    @title = "signup"
    erb :signup
end

post '/signup' do

    name = params[:name]            #view側で送信されたnameを受け取る
    email = params[:email]          #view側で送信されたemailを受け取る
    password = params[:password]    #view側で送信されたpasswordを受け取る
    confirmation = params[:confirmation]  #view側で送信されたconfirmationを受け取る

    redirect '/signup' if password != confirmation #もしpasswordとconfirmationが違う時 /signupにリダイレクトされる。

    client.exec_params('insert into users(name,email,password) values($1,$2,$3)',[name,email,password])# usersテーブルに上で定義した変数(name,email,pass)の中身を入れる。

    redirect '/login' 

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
    check_login
    @title = "今日の美女"
    @name = session[:user]
    return erb :main
end

post '/main' do 

    redirect '/result'
end

#マイページ
get "/mypage" do
    check_login
    @title = "マイページ"
    return erb :mypage
end

# マイページ・ログアウト用
post "/mypage" do 
    session[:user] = nil
    redirect '/login'
end

############################### 美女リスト###############################
get "/list" do
    check_login
    @title = "bijolist"
    @images  = [
        "吉岡里帆.jpg","吉岡里帆2.jpg", "波瑠.jpg","えなこ.jpg","おのののか.jpg",
        "こばしり.jpg","ツウィ.jpg","ナヨン.jpg","マーシュ彩.jpg",
        "マーフィー波奈.jpg","ミナ.jpg","モモ.jpg","ロンモンロウ.jpg",
        "綾瀬はるか.jpg","井口綾子.jpg","宇垣美里.jpg","羽柴なつみ.jpg",
        "衛藤美彩.jpg","加藤玲奈.jpg","喜多乃愛.jpg","橋本環奈.jpg",
        "橋本奈々未.jpg","原奈々美.jpg","戸田恵梨香.jpg","広瀬アリス.jpg",
        "広瀬すず.jpg","弘中綾香.jpg","高田里穂.jpg","高畑充希.jpg",
        "黒木ひかり.jpg","今田美桜.jpg","佐々木希.jpg","佐野ひなこ.jpg",
        "菜々緒.jpg","桜井日奈子.jpg","三吉彩花.jpg","山本舞香.jpg","志田未来.jpg",
        "十味.jpg","小坂菜緒.jpg","小室安未.jpg","小芝風花.jpg","小倉優香.jpg",
        "小嶋陽菜.jpg","松岡茉優.jpg","松下玲緒菜.jpg","松田るか.jpg","松本愛.jpg",
        "上野樹里.jpg","新垣結衣.jpg","新木優子.jpg","深川麻衣.jpg","深田恭子.jpg",
        "水湊みお.jpg","清野菜名.jpg","生田絵梨花.jpg","西村歩乃果.jpg","西野七瀬.jpg",
        "石原さとみ.jpg","石田ニコル.jpg","川口春奈.jpg","泉里香.jpg","多部未華子.jpg",
        "大石絵理.jpg","大島優子.jpg","沢尻エリカ.jpg","谷川菜奈.jpg","丹羽仁希.jpg",
        "池上紗理依.jpg","池田エライザ.jpg","中条あやみ.jpg","中村アン.jpg",
        "朝比奈彩.jpg","長澤まさみ.jpg","長濱ねる.jpg","田中みな実.jpg","田中真琴.jpg",
        "渡邉理佐.jpg","土屋太鳳.jpg","桃月なしこ.jpg","内田理央.jpg","二階堂ふみ.jpg",
        "能年玲奈.jpg","馬場ふみか.jpg","白石聖.jpg","白石麻衣.jpg","飯豊まりえ.jpg",
        "浜辺美波.jpg","武井咲.jpg","武田玲奈.jpg","芳根京子.jpg","北川景子.jpg","牧野真莉愛.jpg",
        "堀田茜.jpg","本田翼.jpg","有村架純.jpg","与田祐希.jpg","鈴木えみ.jpg","鈴木愛理.jpg",
        "齋藤飛鳥.jpg","筧美和子.jpg","齊藤京子.jpg"]

    return erb :list



end

############################### 結果 ################################ 
get "/result" do
    check_login
    @title = "result"

    #---------------------------- ランダム画像表示 ----------------------------
    @images  = [
        "吉岡里帆.jpg","吉岡里帆2.jpg", "波瑠.jpg","えなこ.jpg","おのののか.jpg",
        "こばしり.jpg","ツウィ.jpg","ナヨン.jpg","マーシュ彩.jpg",
        "マーフィー波奈.jpg","ミナ.jpg","モモ.jpg","ロンモンロウ.jpg",
        "綾瀬はるか.jpg","井口綾子.jpg","宇垣美里.jpg","羽柴なつみ.jpg",
        "衛藤美彩.jpg","加藤玲奈.jpg","喜多乃愛.jpg","橋本環奈.jpg",
        "橋本奈々未.jpg","原奈々美.jpg","戸田恵梨香.jpg","広瀬アリス.jpg",
        "広瀬すず.jpg","弘中綾香.jpg","高田里穂.jpg","高畑充希.jpg",
        "黒木ひかり.jpg","今田美桜.jpg","佐々木希.jpg","佐野ひなこ.jpg",
        "菜々緒.jpg","桜井日奈子.jpg","三吉彩花.jpg","山本舞香.jpg","志田未来.jpg",
        "十味.jpg","小坂菜緒.jpg","小室安未.jpg","小芝風花.jpg","小倉優香.jpg",
        "小嶋陽菜.jpg","松岡茉優.jpg","松下玲緒菜.jpg","松田るか.jpg","松本愛.jpg",
        "上野樹里.jpg","新垣結衣.jpg","新木優子.jpg","深川麻衣.jpg","深田恭子.jpg",
        "水湊みお.jpg","清野菜名.jpg","生田絵梨花.jpg","西村歩乃果.jpg","西野七瀬.jpg",
        "石原さとみ.jpg","石田ニコル.jpg","川口春奈.jpg","泉里香.jpg","多部未華子.jpg",
        "大石絵理.jpg","大島優子.jpg","沢尻エリカ.jpg","谷川菜奈.jpg","丹羽仁希.jpg",
        "池上紗理依.jpg","池田エライザ.jpg","中条あやみ.jpg","中村アン.jpg",
        "朝比奈彩.jpg","長澤まさみ.jpg","長濱ねる.jpg","田中みな実.jpg","田中真琴.jpg",
        "渡邉理佐.jpg","土屋太鳳.jpg","桃月なしこ.jpg","内田理央.jpg","二階堂ふみ.jpg",
        "能年玲奈.jpg","馬場ふみか.jpg","白石聖.jpg","白石麻衣.jpg","飯豊まりえ.jpg",
        "浜辺美波.jpg","武井咲.jpg","武田玲奈.jpg","芳根京子.jpg","北川景子.jpg","牧野真莉愛.jpg",
        "堀田茜.jpg","本田翼.jpg","有村架純.jpg","与田祐希.jpg","鈴木えみ.jpg","鈴木愛理.jpg",
        "齋藤飛鳥.jpg","筧美和子.jpg","齊藤京子.jpg"]
    @random_no = rand(100)
    @random_image = @images[@random_no]
    @random_image_removejpg = @random_image.delete("2.jpg")

    #---------------------- ランダムテキスト表示----------------------------

    @kindtext = ["なんだ、かっこいいじゃん","目標に向かってるその姿、好きだよ","よし、今日も頑張ろっか","優しいところ好き","いつも頑張ってる姿見てるよ","今日頑張ったら、後でご褒美上げる","今日もちゃんと起きれたね、偉い偉い",]
    @nice_text = rand(7)
    @random_text = @kindtext[@nice_text]

    return erb :result
end


#-------------- マイ美女 -----------------
get '/mybijo' do
    check_login
    return erb :mybijo
end


post "/mybijo" do
    @value1 = params[:value1]
    @value2 = params[:value2]
    @value3 = params[:value3]
    if !params[:img].nil? # データがあれば処理を続行する
        tempfile = params[:img][:tempfile] # ファイルがアップロードされた場所
        save_to = "./public/images/#{params[:img][:filename]}" # ファイルを保存したい場所
        FileUtils.mv(tempfile, save_to)
        @img_name = params[:img][:filename]
    end
    return erb :mybijo
end