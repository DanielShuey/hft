class Simulator < Struct.new :filename, :btc
  attr_accessor :currency_btc, :currency_other, :transactions, :strategy, :fees

  def initialize **args
    args.each_pair { |k, v| send "#{k}=", v }
    @transactions = []
  end

  def dataset
    @dataset ||= Ohlc.from_json(IO.read(File.join(Sinatra::Application.settings.root, 'assets', 'data', "#{filename}.json")))
  end

  def apply strategy
    @strategy = strategy
    @strategy.dataset = dataset
    @currency_btc = btc
    @last_btc = btc
    @currency_other = 0
    @fees = 0
    update_balance
  end

  def buy
    @last_btc = currency_btc
    amount = currency_btc * (1.to_f / market_price)
    @currency_other = amount - fee(amount)
    @currency_btc = 0
    @transactions << { date: current.date, type: 'buy', price: current.weighted_average, amount: @currency_other }
    @fees += fee(currency_btc)
  end

  def sell
    amount = currency_other * market_price
    @currency_other = 0
    @currency_btc = amount - fee(amount)
    @transactions << { date: current.date, type: 'sell', price: current.weighted_average, amount: @currency_btc, profit: currency_btc - @last_btc, gain: (1-(@last_btc/currency_btc))*100 }
    @fees += fee(amount)
  end

  def current
    dataset[@date]
  end

  def profit
    currency_btc - btc
  end

  def gain
    (1-(btc/currency_btc))*100
  end

  def update_balance
    strategy.set_balance currency_btc, currency_other
  end

  def fee amount
    amount * 0.0025
  end

  def latest_point
    @latest_point ||= strategy.chart.length - 1
  end

  def set_date timestamp
    @date = timestamp
    strategy.set_date timestamp
  end

  def perform
    update_balance

    dataset.each do |timestamp, x|
      set_date timestamp

      buy  if strategy.buy?
      sell if strategy.sell?

      update_balance
    end

    sell if currency_other > 0
  end

  def js_dump
    strategy.js_dump + [ "window.scatter_data = [" + @transactions.map { |x| "{ x: new Date(#{x[:date] * 1000}),y: #{x[:price]}, name: '#{x[:type]}' }" }.join(',') + "];" ].join
  end
end
