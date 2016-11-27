# Gems
require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'sinatra/base'
require 'sass/plugin/rack'

# Sass
use Sass::Plugin::Rack
Sass::Plugin.options[:template_location] = "assets/sass"
Sass::Plugin.options[:css_location] = "public"
Sass::Plugin.options[:style] = :pretty

# Coffeescript
use Rack::Coffee, root: 'public', urls: 'assets/coffee', join: 'app'
Tilt::CoffeeScriptTemplate.default_bare = true

# Slim
Slim::Engine.set_options pretty: true, sort_attrs: false

# App
Dir[File.expand_path('..', __FILE__) + "/app/**/*.rb"].each do |file|
  require file
end

run App.new
