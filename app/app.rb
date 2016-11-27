class App < Sinatra::Base
  configure do
    set :public_folder, 'public'
  end

  get "/" do
    slim :index    
  end

  not_found do
    redirect '/404.html'
  end

  def get_data2
    HTTP.get("https://poloniex.com/public?command=returnChartData&currencyPair=BTC_XMR&start=1480032000&end=1480118400&period=7200") do |response|
      if response.ok?
        response.json
      end
    end
  end
end
