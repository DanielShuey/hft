class App < Sinatra::Base
  configure do
    register Barista::Integration::Sinatra
    set :public_folder, 'public'
    set :root, File.expand_path('../../', __FILE__)
    set :views, File.join(root, '/assets/slim/')
  end

  def include_slim(name, options = {}, &block)
    Slim::Template.new(File.join(settings.views, "#{name}.slim"), options).render(self, &block)
  end

  get "/" do
    slim :index, layout: :layout
  end

  def mock_data
    IO.read(File.join(settings.root, 'assets', 'data', 'mock.json'))
  end

  def get_data2
    HTTP.get("https://poloniex.com/public?command=returnChartData&currencyPair=BTC_XMR&start=1480032000&end=1480118400&period=300") do |response|
      if response.ok?
        response.json
      end
    end
  end
end
