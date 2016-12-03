class StochRsi
  include Indicator

  attr_reader :result, :start_date, :current

  attributes *%i(rsi stoch_rsi change gain loss average_gain average_loss sma)

  dataset do
    changes
    gains
    losses
    average_gains
    average_losses
    rsi
    stoch_rsi
    sma
  end

  def initialize
    @period = 14
  end

  def overbought?
    current.stoch_rsi > 0.8 if current.stoch_rsi
  end

  def oversold?
    current.stoch_rsi < 0.2 if current.stoch_rsi
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
