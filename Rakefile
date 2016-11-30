# Load Path
$:.unshift File.expand_path('..', __FILE__)

# Boot
require 'config/init.rb'


task :update_current_data do
  
end

def hours_to_timestamp hours
  (DateTime.now - (hours.to_f/24.to_f)).to_time.to_i
end

def current_timestamp
  Time.now.getutc.to_i
end

def get_period arg
  periods = {
    '5mins' => 300,
    '15mins' => 900,
    '30mins' => 1800,
    '2hours' => 7200,
    '4hours' => 14400,
    '1day' => 86400,
  } 
  return periods[arg]
end

task :update_balances do
  api_key = "74FVB4RQ-CRM3THOF-KCH4A1SH-M8NXNXSK"
end

task :update_current do
  currency_pair = 'BTC_XMR'
  start_time = hours_to_timestamp 168
  period = get_period '30mins'

  HTTParty.get("https://poloniex.com/public?command=returnChartData&currencyPair=#{currency_pair}&start=#{start_time}&end=#{current_timestamp}&period=#{period}").tap do |response|
    File.open(File.join(Config.root, 'assets', 'data', 'current.json'), 'w') { |f| f.write(response.body) }
  end
end
 
task :update_historic do
  currency_pair = 'BTC_XMR'
  start_time = hours_to_timestamp 168
  period = get_period '5mins'

  HTTParty.get("https://poloniex.com/public?command=returnChartData&currencyPair=#{currency_pair}&start=#{start_time}&end=#{current_timestamp}&period=#{period}").tap do |response|
    File.open(File.join(Config.root, 'assets', 'data', 'historic.json'), 'w') { |f| f.write(response.body) }
  end
end

task :run_simulation do
  sim = Simulator.new filename: 'test1', btc: 0.2
  sim.apply StochRsi.new
  sim.perform
  puts sim.transactions
  puts "Start: #{sim.btc} | End: #{sim.currency_btc}"
  puts "Profit: #{sim.profit}"
  puts "Gain: #{sim.gain}"
  puts "Fees: #{sim.fees}"
end

task :optimize do
  
end



