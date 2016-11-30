class StochRsi
  attr_reader :result, :start_date, :current

  class DataPoint < Ohlc
    attributes *%i(rsi stoch_rsi change gain loss average_gain average_loss sma)
  end

  def dataset dataset
    @result = dataset.map { |set| DataPoint.new(set.context) }
    changes
    gains
    losses
    average_gains
    average_losses
    rsi
    stoch_rsi
    sma
    @start_date = find_start_date
  end

  def initialize
    @period = 14
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

  def uptrend?
    if current.sma
      if @currency_a >= @currency_b
        true if current.sma > 0.5
      end
    end
  end

  def downtrend?
    if current.sma
      if @currency_a <= @currency_b
        true if current.sma < 0.5
      end
    end
  end

  def js_dump
    def dump result, method
      "{ x: new Date(#{result.date * 1000}), y: #{result.send method} }" if result.send method
    end

    [
      "window.rsi_data = [" + result.map { |x| (dump x, :sma) }.compact.join(',') + "];"
    ].join("\n")
  end

  private

  def find_start_date
    result.each do |datapoint|
      return datapoint.date if DataPoint.attributes.map{ |x| datapoint.send x }.compact.length == DataPoint.attributes.length
    end
  end

  def changes
    result.each_cons(2) do |left, right|
      datapoint(right.date).change = right.weighted_average - left.weighted_average
    end
  end

  def gains
    result.each do |x|
      next unless x.change
      datapoint(x.date).gain = x.change > 0 ? x.change.abs : 0 
    end
  end

  def losses
    result.each do |x|
      next unless x.change
      datapoint(x.date).loss = x.change < 0 ? x.change.abs : 0
    end
  end

  def average_gains
    result.each_cons(@period) do |x|
      next unless x.first.gain
      datapoint(x.last.date).average_gain = x.map(&:gain).sum / @period
    end
  end

  def average_losses
    result.each_cons(@period) do |x|
      next unless x.first.loss
      datapoint(x.last.date).average_loss = x.map(&:loss).sum / @period
    end
  end

  def rsi
    result.each do |x|
      next unless x.average_gain
      rs = x.average_gain / x.average_loss
      datapoint(x.date).rsi = 100 - (100 / (1 + rs))
    end
  end

  def stoch_rsi
    result.each_cons(@period) do |x|
      next unless x.first.rsi
      rsi_highest = x.map(&:rsi).max
      rsi_lowest = x.map(&:rsi).min
      datapoint(x.last.date).stoch_rsi = (x.last.rsi - rsi_lowest) / (rsi_highest - rsi_lowest)
    end
  end

  def sma
    result.each_cons(5) do |x|
      next unless x.first.stoch_rsi
      datapoint(x.last.date).sma = x.map(&:stoch_rsi).sma
    end
  end

end
