class Dema
  include Indicator

  attr_reader :result, :start_date, :current, :long_period, :short_period

  attributes *%i(long short dema)

  dataset do
    long
    short
    dema
  end

  def initialize
    @short_period = 5
    @long_period = 10
  end

  def uptrend?
    if current.dema && current.long
      diff = current.dema / current.long
      if diff > 1
        true
      end
    end
  end

  def downtrend?
    if current.dema && current.long
      diff = current.dema / current.long
      if diff < 1
        true
      end
    end
  end

  def js_dump
    def dump result, method
      "{ x: new Date(#{result.date * 1000}), y: #{result.send method} }" if result.send method
    end

    [
      "window.long_data = [" + result.map { |x| dump x, :long }.compact.join(',') + "];",
      "window.short_data = [" + result.map { |x| dump x, :dema }.compact.join(',') + "];",
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

  def dema
    result.each_cons(short_period) do |x|
      next unless x.first.short
      datapoint(x.last.date).dema = (2 * x.last.short) - x.map(&:short).ema
    end
  end
end
