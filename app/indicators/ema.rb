class Ema
  include Indicator

  attr_reader :long_period, :short_period

  attributes *%i(long short trend crossover ema_ratio)

  dataset do
    longs
    shorts
    ema_ratio
    trends
    crossovers
  end
 
  def initialize long: 20, short: 5
    @short_period = short
    @long_period = long
  end

  def value
    current.ema_ratio
  end

  def uptrend?
    current.trend == :up
  end

  def downtrend?
    current.trend == :down
  end

  def positive_crossover?
    current.crossover == :up
  end

  def negative_crossover?
    current.crossover == :down
  end

  def js_dump
    def dump result, method
      "{ x: new Date(#{result.date * 1000}), y: #{result.send method} }" if result.send method
    end

    [
      "window.long_data = [" + result.map { |x| dump x, :long }.compact.join(',') + "];",
      "window.short_data = [" + result.map { |x| dump x, :short }.compact.join(',') + "];",
    ].join("\n")
  end

  private

  def ema_ratio
    result.each do |x|
      next unless x.short && x.long
      datapoint(x.date).ema_ratio = x.short / x.long
    end
  end

  def trends
    result.each do |x|
      next unless x.ema_ratio
      datapoint(x.date).trend = x.ema_ratio >= 1 ? :up : :down
    end
  end

  def crossovers
    result.each_cons(2) do |x|
      next unless x.first.trend
      if x.first.trend == :up && x.last.trend == :down
        datapoint(x.last.date).crossover = :down
      end
      if x.first.trend == :down && x.last.trend == :up
        datapoint(x.last.date).crossover = :up
      end
      if x.first.trend == x.last.trend
        datapoint(x.last.date).crossover = :none
      end
    end
  end

  def longs
    result.each_cons(long_period) do |x|
      datapoint(x.last.date).long = x.map(&:weighted_average).sma
    end
  end

  def shorts
    result.each_cons(short_period) do |x|
      datapoint(x.last.date).short = x.map(&:weighted_average).ema
    end
  end
end
