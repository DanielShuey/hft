class Dema
  attr_reader :result, :start_date, :current, :long_period, :short_period

  class DataPoint < Ohlc
    attributes *%i(long short dema)
  end

  def dataset dataset
    @result = dataset.map { |set| DataPoint.new(set.context) }
    long
    short
    dema
    @start_date = find_start_date
  end

  def initialize
    @short_period = 5
    @long_period = 20
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
    if @currency_a >= @currency_b
      diff = current.dema / current.long
      if diff > 1.001
        true
      end
    end
  end

  def downtrend?
    if @currency_a <= @currency_b
      diff = current.dema / current.long
      if diff < 0.999
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
      "window.short_data = [" + result.map { |x| dump x, :short }.compact.join(',') + "];",
      "window.dema_data = [" + result.map { |x| dump x, :dema }.compact.join(',') + "];"
    ].join("\n")
  end

  private

  def find_start_date
    result.each do |datapoint|
      return datapoint.date if DataPoint.attributes.map{ |x| datapoint.send x }.compact.length == DataPoint.attributes.length
    end
  end

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
