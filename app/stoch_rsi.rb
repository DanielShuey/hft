class StochRsi
  attr_reader :result, :start_date, :current

  class DataPoint < Ohlc
    attributes *%i(rsi stoch_rsi average_gain average_loss)
  end

  def dataset dataset
    @result = dataset.map { |set| DataPoint.new(set.context) }
    average_gains
    average_losses
    rsi
    stoch_rsi
    @start_date = find_start_date
  end

  def initialize
    @period = 7
  end

  def datapoint timestamp
    result.find { |x| x.date == timestamp }
  end

  def set_date timestamp
    @current = datapoint(timestamp)
  end

  def set_balance a, b
    @currency_a = a
    @currency_b = b
  end

  def buy?
    if current.stoch_rsi
      if @currency_a >= @currency_b
        true if current.stoch_rsi > 0.7
      end
    end
  end

  def sell?
    if current.stoch_rsi
      if @currency_a <= @currency_b
        true if current.stoch_rsi < 0.3
      end
    end
  end

  def js_dump
    def dump result, method
      "{ x: new Date(#{result.date * 1000}), y: #{result.send method} }" if result.send method
    end

    [
      "window.rsi_data = [" + result.map { |x| (dump x, :stoch_rsi) }.compact.join(',') + "];"
    ].join("\n")
  end

  private

  def find_start_date
    result.each do |datapoint|
      return datapoint.date if DataPoint.attributes.map{ |x| datapoint.send x }.compact.length == DataPoint.attributes.length
    end
  end

  def average_gains
    result.each_cons(@period).each do |x|
      datapoint(x.last.date).average_gain = x.each_cons(2).map  do |left, right|
        gain = right.weighted_average - left.weighted_average
        gain > 0 ? gain.abs : 0
      end.sum / (@period - 1)
    end
  end

  def average_losses
    result.each_cons(@period).each do |x|
      datapoint(x.last.date).average_loss = x.each_cons(2).map  do |left, right|
        gain = right.weighted_average - left.weighted_average
        gain < 0 ? gain.abs : 0
      end.sum / (@period - 1)
    end
  end

  def stoch_rsi
    result.each_cons(@period).each do |x|
      next if !x.first.rsi
      rsi_highest = x.map(&:rsi).max
      rsi_lowest = x.map(&:rsi).min
      datapoint(x.last.date).stoch_rsi = (x.last.rsi - rsi_lowest) / (rsi_highest - rsi_lowest)
    end
  end

  def rsi
    result.each do |x|
      next if !x.average_gain
      rs = x.average_gain / x.average_loss
     datapoint(x.date).rsi = 100 - (100 / (1 + rs))
    end
  end
end
