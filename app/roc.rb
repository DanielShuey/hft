class Roc
  attr_accessor :ohlc

  def initialize length:, ohlc: nil
    @length = length
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
    (@ohlc.length - [short.length, dema.length].min) + @length + 2
  end

  def data_point
    chart[@index]
  end

  def set_balance a, b
    @currency_a = a
    @currency_b = b
  end

  def spline
    @spline = Spliner::Spliner.new (earliest_point..-1), dema
  end

  def rate_of_change
    finish = chart[@index]
    start = chart[@index-4]
    
    finish[:dema] / start[:dema]
  end

  def threshold
    0.001
  end

  def buy?
    if @currency_a >= @currency_b
      if rate_of_change > 1 + threshold
       puts rate_of_change
        true
      end
    end
  end

  def sell?
    if @currency_a <= @currency_b
      if rate_of_change < 1 - threshold
        puts rate_of_change
        true
      end
    end
  end

  def dema
    @dema ||= short.each_cons(@length).map { |x| (2 * x.last) - x.ema }
  end

  def short
    @short ||= averages.each_cons(@length).map(&:ema)
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
        short: i > @length ? short[i - @length] : nil,
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
      "window.dema_data = [" + chart.map { |x| dump x, :dema }.compact.join(',') + "];",
      "window.short_data = [" + chart.map { |x| dump x, :short }.compact.join(',') + "];",
      "window.volume = [" + chart.map { |x| dump x, :volume }.compact.join(',') + "];"
    ].join("\n")
  end
end
