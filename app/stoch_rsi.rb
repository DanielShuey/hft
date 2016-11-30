class StochRsi
  attr_reader :result, :start_date

  class DataPoint < Ohlc
    attributes %i(rsi stoch_rsi average_gain average_loss)
  end

  def dataset dataset
    @result = dataset.map { |date, set| [date, DataPoint.new **set.context] }.to_h
    average_gains
    average_losses
    rsi
    stoch_rsi
    @start_date = find_start_date
  end

  def initialize
    @period = 7
  end

  def set_date timestamp
    @timestamp = timestamp
  end

  def current
    result[@timestamp]
  end

  def set_balance a, b
    @currency_a = a
    @currency_b = b
  end

  def buy?
    if @currency_a >= @currency_b
      true if current.stoch_rsi > 0.7
    end
  end

  def sell?
    if @currency_a <= @currency_b
      true if current.stoch_rsi < 0.3
    end
  end

  def js_dump
    def dump result, method
      "{ x: new Date(#{result.date * 1000}), y: #{result.send method} }" if chart[method] != nil
    end

    [
      "window.line2_data = [" + result.map { |date, x| (dump x, :stoch_rsi) if date >= start_time }.compact.join(',') + "];"
    ].join("\n")
  end

  private

  def find_start_date
    result.each do |date, x|
      return date if (DataPoint.attributes.map { |x| result.send x }.compact.length == DataPoint.attributes.length)
    end
  end

  def average_gains
    result.each_cons(@period + 1) do |date, points|
      result[points.last.date].average_gain = points.each_cons(2).map do |x|
        gain = x[1].weighted_average - x[0].weighted_average
        gain > 0 ? gain.abs : 0
      end.sum / @period
    end
  end

  def average_losses
    result.each_cons(@period + 1) do |date, points|
      result[points.last.date].average_loss = points.each_cons(2).map do |x|
        gain = x[1].weighted_average - x[0].weighted_average
        gain < 0 ? gain.abs : 0
      end.sum / @period
    end
  end

  def stoch_rsi
    result.each_cons(@period) do |date, x|
      next if !x.first.rsi
      rsi_highest = x.map(&:rsi).max
      rsi_lowest = x.map(&:rsi).low 
      result[x.last.date].stoch_rsi = (x.last.rsi - rsi_lowest) / (rsi_highest - rsi_lowest)
    end
  end

  def rsi
    result.each do |date, x|
      next if !x.average_gain
      rs = x.average_gain / x.average_loss
      result[date].rsi = 100 - (100 / (1 + rs))
    end
  end
end
