class HeartBeatWonderLandApp < Sinatra::Base

  set :erb, :escape_html => true
  set :views, Proc.new { File.join(root, "templates") }

  configure do
    use OmniAuth::Builder do
      provider :fitbit_oauth2, ENV['FITBIT_CLIENT_ID'], ENV['FITBIT_CLIENT_SECRET'],
               :scope => 'profile heartrate',
               :expires_in => '2592000'
    end
  end

  get '/' do
    if session[:access_token]
      erb :index
    else
      erb :guest
    end
  end

  get '/auth/fitbit_oauth2/callback' do
    session[:user_name] = env['omniauth.auth']['info']['display_name']
    session[:access_token] = env['omniauth.auth']['credentials'].token

    redirect to '/'
  end

  get '/bpm' do
    res = JSON.parse RestClient.get 'https://api.fitbit.com/1/user/-/activities/heart/date/today/1d.json', :Authorization => "Bearer #{session[:access_token]}"
    latest_data = res["activities-heart-intraday"]['dataset'].last

    value = latest_data['value']

    redirect to "/bpm/#{value}"
  end

  get '/bpm/:bpm' do
    @bpm = params[:bpm].to_i
    halt 400 unless @bpm > 0

    erb :bpm
  end

  get '/logout' do
    session.clear
    redirect to('/')
  end
end
