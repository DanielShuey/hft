class StochRsi
  attr_accessor :ohlc

  def initialize period: 7, ohlc: nil
    @period = period
    @ohlc = ohlc
    @index = @ohlc.length - 1 if ohlc
  end

  def averages
    @averages ||= @ohlc.map(&:weighted_average)
  end

  def set_point index
    @index = index
  end

  def earliest_point
    (@ohlc.length - stoch_rsi.length) + 1
  end

  def average_gains
    @gains ||= averages.each_cons(@period).map do |x|
      x.each_cons(2).map do |y|
        gain = y[1] - y[0]
        gain > 0 ? gain : 0
      end.sum / (@period - 1)
    end
  end

  def average_losses
    @losses ||= averages.each_cons(@period).map do |x|
      x.each_cons(2).map do |y|
        gain = y[1] - y[0]
        gain < 0 ? gain.abs : 0
      end.sum / (@period - 1)
    end
  end

  def stoch_rsi
    @stoch_rsi ||= rsi.each_cons(@period).each_with_index.map do |x, i|
      (rsi[i] - x.min) / (x.max - x.min)
    end
  end

  def rsi
    @rsi ||= average_gains.zip(average_losses).map { |x| x[0] / x[1] }.map do |rs|
      100 - (100 / (1 + rs))
    end
  end

  def data_point
    chart[@index]
  end

  def set_balance a, b
    @currency_a = a
    @currency_b = b
  end

  def buy?
    if @currency_a >= @currency_b
      true if data_point[:stoch_rsi] > 0.7
    end
    rescue
      binding.pry
  end

  def sell?
    if @currency_a <= @currency_b
      true if data_point[:stoch_rsi] < 0.3
    end
  end

  def chart
    @chart ||= @ohlc[earliest_point..-1].each_with_index.map do |x, i|
      {
        date: x.date * 1000,
        ohlc: %i(open high low close).map(&x.method(:send)),
        open: x.open,
        high: x.high,
        low: x.low,
        close: x.close,
        average: x.weighted_average * 1000,
        volume: x.volume,
        rsi: rsi[i],
        stoch_rsi: stoch_rsi[i]
      }
    end
  end

  def js_dump
    def dump chart, method
      "{ x: new Date(#{chart[:date]}), y: #{chart[method]} }" if chart[method] != nil
    end

    [
      "window.line2_data = [" + chart.map { |x| dump x, :stoch_rsi }.compact.join(',') + "];"
    ].join("\n")
  end
end
