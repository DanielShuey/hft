class Simulator
  attr_accessor :filename, :btc, :currency_btc, :currency_other, :transactions, :scan, :fees, :current

  def initialize **args
    args.each_pair { |k, v| send "#{k}=", v }
    @transactions = []
  end

  def dataset
    @dataset ||= Ohlc.from_json(IO.read(File.join(Config.root, 'assets', 'history', "#{filename}.json")))
  end

  def apply scan
    @scan = scan
    @scan.dataset dataset
    @currency_btc = btc
    @last_btc = btc
    @currency_other = 0
    @fees = 0
    update_balance
  end

  def buy
    @last_btc = currency_btc
    amount = currency_btc * (1.to_d / current.weighted_average)
    @currency_other = amount - fee(amount)
    @currency_btc = 0
    @transactions << { date: current.date, type: :buy, price: current.weighted_average, amount: @currency_other }
    @fees += fee(currency_btc)
  end

  def sell
    amount = currency_other * current.weighted_average
    @currency_other = 0
    @currency_btc = amount - fee(amount)
    @transactions << { date: current.date, type: :sell, price: current.weighted_average, amount: @currency_btc, profit: currency_btc - @last_btc, gain: (1-(@last_btc/currency_btc))*100 }
    @fees += fee(amount)
  end

  def profit
    currency_btc - btc
  end

  def lazy_profit
    @dataset.last.weighted_average - @dataset.first.weighted_average
  end

  def gain
    ((currency_btc - btc) / btc) * 100
  end

  def update_balance
    scan.set_balance currency_btc, currency_other
  end

  def fee amount
    amount * 0.0025
  end

  def set_date timestamp
    @current = dataset.find { |x| x.date == timestamp }
    scan.set_date timestamp
  end

  def perform
    update_balance

    dataset.each do |x|
      set_date x.date

      buy  if scan.buy?
      sell if scan.sell?

      update_balance
    end

    sell if currency_other > 0
  end

  def js_dump
    scan.js_dump + [ 
      "window.ohlc_data = [" + dataset.map { |x| "{ x: new Date(#{x.date*1000}), y: [#{x.open},#{x.high},#{x.low},#{x.close}] }"}.compact.join(',') + "];",
      "window.average_data = [" + dataset.map { |x| "{ x: new Date(#{x.date*1000}), y: #{x.weighted_average} }" }.compact.join(',') + "];",
      "window.buy_data = [" + @transactions.select { |x| x[:type] == :buy }.map { |x| "{ x: new Date(#{x[:date] * 1000}),y: #{x[:price]}, name: '#{x[:type]}' }" }.join(',') + "];",
      "window.sell_data = [" + @transactions.select { |x| x[:type] == :sell }.map { |x| "{ x: new Date(#{x[:date] * 1000}),y: #{x[:price]}, name: '#{x[:type]}' }" }.join(',') + "];"  
    ].join("\n")
  end
end
