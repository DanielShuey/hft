class Config
  class << self
    def root
      File.expand_path('../../', __FILE__)
    end
  end
end

# Gems
require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'sinatra/base'
require 'sass/plugin/rack'
require 'openssl'
require "addressable/uri"
require 'bigdecimal'
require 'bigdecimal/util'

# Sass
use Sass::Plugin::Rack
Sass::Plugin.options[:template_location] = "assets/sass"
Sass::Plugin.options[:css_location] = "public/css"
Sass::Plugin.options[:style] = :pretty

# Coffeescript
use Barista::Server::Proxy
Barista.setup_defaults
Barista.app_root = Config.root
Barista.root = 'assets/coffee'
Barista.output_root = 'public/js'
Barista.bare = true
Tilt::CoffeeScriptTemplate.default_bare = true

# Slim
Slim::Engine.set_options pretty: true, sort_attrs: false

# Autoload
class Object
  def self.const_missing name
    @autoload_files ||= Dir[File.join(Config.root, "/app/**/*.rb")].map do |file|
      [File.basename(file, '.rb').classify.to_sym, file]
    end.to_h

    if @autoload_files[name]
      require @autoload_files[name]
      Object.const_get(name)
    else
      super
    end
  end
end
