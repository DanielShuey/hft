# Load Path
$:.unshift File.expand_path('..', __FILE__)

# Boot
require 'config/init.rb'

def backtrack hours
  (DateTime.now - (hours.to_f/24.to_f)).to_time.to_i
end

task :run_robot do

end

task :update_balance do
  Poloniex.available_balance.tap do |response|
    File.open(File.join(Config.root, 'assets', 'response_cache', 'available_balance.json'), 'w') { |f| f.write(response.body) } if response.ok?
  end
end

task :update_complete_balance do
  Poloniex.available_balance.tap do |response|
    File.open(File.join(Config.root, 'assets', 'response_cache', 'available_balance.json'), 'w') { |f| f.write(response.body) } if response.ok?
  end
end

task :update_current do
 Poloniex.chart_data(currency_pair: 'BTC_XMR', start: backtrack(36), period: '5mins').tap do |response|
    File.open(File.join(Config.root, 'assets', 'response_cache', 'chart.json'), 'w') { |f| f.write(response.body) }
  end
end
 
task :update_historic do
 Poloniex.chart_data(currency_pair: 'BTC_XMR', start: backtrack(36), period: '5mins').tap do |response|
    File.open(File.join(Config.root, 'assets', 'response_cache', 'chart.json'), 'w') { |f| f.write(response.body) }
  end
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
