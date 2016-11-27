root = File.expand_path('..', __FILE__)

# Gems
require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'sinatra/base'
require 'sass/plugin/rack'

# Sass
use Sass::Plugin::Rack
Sass::Plugin.options[:template_location] = "assets/sass"
Sass::Plugin.options[:css_location] = "public/css"
Sass::Plugin.options[:style] = :pretty

# Coffeescript
use Barista::Server::Proxy
Barista.setup_defaults
Barista.app_root = root
Barista.root = 'assets/coffee'
Barista.output_root = 'public/js'
Barista.bare = true
Tilt::CoffeeScriptTemplate.default_bare = true

# Slim
Slim::Engine.set_options pretty: true, sort_attrs: false

# App
Dir[File.join(root, "/app/**/*.rb")].each do |file|
  require file
end

run App.new
