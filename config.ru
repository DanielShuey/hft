# Load Path
$:.unshift File.expand_path('..', __FILE__)

# Boot
require 'config/init.rb'

# App
run App.new
