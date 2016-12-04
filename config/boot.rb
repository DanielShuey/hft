require 'openssl'
require "addressable/uri"
require 'bigdecimal'
require 'bigdecimal/util'
require 'yaml'

class Config
  class << self
    def root
      File.expand_path('../../', __FILE__)
    end

    YAML.load_file(File.join(Config.root, 'temp', 'config.yml')).each do |k, v|
      define_method(k) { v }
    end

    def currency_pair
      "BTC_#{currency.to_s.upcase}"
    end
  end
end

# Autoload
class Object
  def self.const_missing name
    @autoload_files ||= Dir[File.join(Config.root, "/app/**/*.rb")].map do |file|
      [File.basename(file, '.rb').camelize.to_sym, file]
    end.to_h

    if @autoload_files[name]
      require @autoload_files[name]
      Object.const_get(name)
    else
      super
    end
  end
end

# Loggers
`touch #{File.join(Config.root, 'temp', 'history.txt')}`
def history msg
  `echo '#{msg}' >> #{File.join(Config.root, 'temp', 'history.txt')}`
end

# Make Temp Directories

require 'fileutils'
FileUtils::mkdir_p File.join(Config.root, 'temp', 'responses')
