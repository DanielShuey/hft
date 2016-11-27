# Gems
require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'sinatra/base'
require 'sass/plugin/rack'

# Sass
use Sass::Plugin::Rack
Sass::Plugin.options[:style] = :pretty
Sass::Plugin.add_template_location 'assets/stylesheets'

# Coffeescript
use Rack::Coffee, root: 'public', urls: 'assets/javascripts', join: 'app'
Tilt::CoffeeScriptTemplate.default_bare = true

# Slim
Slim::Engine.set_options pretty: true, sort_attrs: false

# App
Dir[root_path("app/**/*.rb")].each do |file|
  require file
end

run App.new
