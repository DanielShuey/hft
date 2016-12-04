class Pressure
  include Indicator

  attr_reader :result, :start_date, :current

  attributes *%i(pressure direction normalized_pressure)

  dataset do
    pressure
    direction
    normalize
  end

  def initialize
    @period = 30
  end

  def uptrend?
    current.normalized_pressure >= 0.5 if current.normalized_pressure
  end

  def downtrend?
    current.normalized_pressure <= -0.5 if current.normalized_pressure
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
      datapoint(x.last.date).normalized_pressure = (x[-3..-1].map(&:pressure).ema / x.map(&:pressure).max) * x.last.direction
    end
  end
end
