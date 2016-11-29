class Dema
  attr_accessor :ohlc

  def initialize long:, short:, ohlc: nil
    @long_duration = long
    @short_duration = short
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
    (@ohlc.length - [long.length, short.length, dema.length].min) + 2
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
      diff = data_point[:dema] / data_point[:long]
      if diff > 1.001
        true
      end
    end
  end

  def sell?
    if @currency_a <= @currency_b
      diff = data_point[:dema] / data_point[:long]
      if diff < 0.999
        true
      end
    end
  end

  def long
    @long ||= averages.each_cons(@long_duration).map(&:sma)
  end

  def dema
    @dema ||= short.each_cons(@short_duration).map { |x| (2 * x.last) - x.ema }
  end

  def short
    @short ||= averages.each_cons(@short_duration).map(&:ema)
  end

  def chart
    dema_duration = @ohlc.length - dema.length

    @chart ||= @ohlc.each_with_index.map do |x, i|
      {
        date: x.date * 1000,
        ohlc: %i(open high low close).map(&x.method(:send)),
        open: x.open,
        high: x.high,
        low: x.low,
        close: x.close,
        average: x.weighted_average,
        volume: x.volume,
        long: i > @long_duration ? long[i - @long_duration] : nil,
        short: i > @short_duration ? short[i - @short_duration] : nil,
        dema: i > dema_duration ? dema[i - dema_duration] : nil
      }
    end
  end

  def js_dump
    def dump chart, method
      "{ x: new Date(#{chart[:date]}), y: #{chart[method]} }" if chart[method] != nil
    end

    [
      "window.ohlc_data = [" + chart.map { |x| dump x, :ohlc }.compact.join(',') + "];",
      "window.average_data = [" + chart.map { |x| dump x, :average }.compact.join(',') + "];",
      "window.long_data = [" + chart.map { |x| dump x, :long }.compact.join(',') + "];",
      "window.short_data = [" + chart.map { |x| dump x, :short }.compact.join(',') + "];",
      "window.dema_data = [" + chart.map { |x| dump x, :dema }.compact.join(',') + "];",
      "window.volume = [" + chart.map { |x| dump x, :volume }.compact.join(',') + "];"
    ].join("\n")
  end
end
