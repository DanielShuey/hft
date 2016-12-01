class Ema
  include Indicator

  attr_reader :result, :start_date, :current, :long_period, :short_period

  attributes *%i(long short)

  dataset do
    long
    short
  end

  def initialize
    @short_period = 20
    @long_period = 40
  end

  def uptrend?
    if current.short && current.long
      current.short / current.long > 1
    end
  end

  def downtrend?
    if current.short && current.long
      current.short / current.long < 1
    end
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

  def long
    result.each_cons(long_period) do |x|
      datapoint(x.last.date).long = x.map(&:weighted_average).sma
    end
  end

  def short
    result.each_cons(short_period) do |x|
      datapoint(x.last.date).short = x.map(&:weighted_average).ema
    end
  end
end
