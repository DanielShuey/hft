class Pressure
  include Indicator

  attr_reader :result, :start_date, :current

  attributes *%i(pressure normal direction positive negative ratio index)

  dataset do
    pressure
    direction
    positive
    negative
    normalize
    ratio
    index
  end

  def initialize
    @period = 30
  end

  def uptrend?
    current.normal >= 0.5 if current.normal
  end

  def downtrend?
    current.normal <= -0.5 if current.normal
  end

  def js_dump
    def dump result, method
      "{ x: new Date(#{result.date * 1000}), y: #{result.send method} }" if result.send method
    end

    [
      "window.pressure_data = [" + result.map { |x| dump x, :normal }.compact.join(',') + "];",
    ].join("\n")
  end

  private

  def pressure
    result.each { |x| datapoint(x.date).pressure = (x.high - x.low) * x.quote_volume }
  end

  def direction
    result.each { |x| datapoint(x.date).direction = x.close >= x.open ? 1 : -1 }
  end

  def normalize
    result.each_cons(@period) do |x|
      next unless x.first.positive
      datapoint(x.last.date).normal = (x[-3..-1].map(&:pressure).ema / x.map(&:pressure).max) * x.last.direction
    end
  end

  def positive
    result.each do |x|
      next unless x.pressure && x.direction
      datapoint(x.date).positive = x.direction == 1 ? x.pressure : 1
    end
  end

  def negative
    result.each do |x|
      next unless x.pressure && x.direction
      datapoint(x.date).negative = x.direction == -1 ? x.pressure : 1
    end
  end

  def ratio
    result.each_cons(@period) do |x|
      next unless x.first.positive
      datapoint(x.last.date).ratio = x.sum(&:positive) / x.sum(&:negative)
    end
  end

  def index
    result.each do |x|
      next unless x.ratio
      datapoint(x.date).index = 100 - (100/(1 + x.ratio))
    end
  end
end
