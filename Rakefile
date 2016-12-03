# Load Path
$:.unshift File.expand_path('..', __FILE__)

# Boot
require 'config/init.rb'

task :run_robot do
  Robot.run :xmr
end

task :run_robot_once do
  Robot.perform :xmr
end

task :buy do
  ChartData.update
  Balance.update
  Ticker.update
  puts Poloniex.buy currency_pair: 'BTC_XMR', rate: Ticker.lowest_ask, amount: Balance.available_btc * (1/Ticker.lowest_ask)
end

task :sell do
  ChartData.update
  Balance.update
  Ticker.update
  puts Poloniex.sell currency_pair: 'BTC_XMR', rate: Ticker.highest_bid, amount: Balance.available_xmr
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
  ChartData.update_historic rewind: 48
end

task :run_simulation do
  sim = Simulator.new filename: '1week5min', btc: 0.2
  sim.apply DemoScan.new
  sim.perform
  puts sim.transactions
  puts "Start: #{sim.btc} | End: #{sim.currency_btc}"
  puts "Profit: #{sim.profit}"
  puts "Gain: #{sim.gain}"
  puts "Fees: #{sim.fees}"
end
