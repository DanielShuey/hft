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

  get "/simulator" do
    slim :simulator, layout: :layout
  end

  def historic_data
    IO.read(File.join(settings.root, 'assets', 'data', 'historic.json'))
  end
end
