# Load Path
$:.unshift File.expand_path('..', __FILE__)

# Gems
require 'rubygems'
require 'bundler'
Bundler.require(:default)

# Boot
require 'config/boot.rb'

task :run_robot do
  Robot.run
end

task :run_robot_once do
  Robot.perform
end

task :update_trade_history do
  
end

task :update_balance do
  Balance.new.update
end

task :update_current do
  ChartData.update
end
 
task :update_historic do
  ChartData.update_historic currency_pair: 'BTC_ETH', rewind: 500, period: '15mins'
end

task :run_simulation do
  sim = Simulator.new filename: 'BTC_ETH-500hrs-15mins', btc: 0.2
  sim.apply DemoScan.new
  sim.perform
  puts sim.transactions
  puts "Start: #{sim.btc.round(5)} | End: #{sim.currency_btc.round(5)}"
  puts "Profit: #{sim.profit.round(5)}"
  puts "Gain: #{sim.gain.round(5)}"
  puts "Fees: #{sim.fees.round(5)}"
end
