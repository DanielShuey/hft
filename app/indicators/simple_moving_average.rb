class SimpleMovingAverage
  include Indicator

  attributes *%i(moving_average)

  dataset do
    moving_averages
  end
 
  def initialize period:
    @period = period
  end

  def js_dump
    def dump result, method
      "{ x: new Date(#{result.date * 1000}), y: #{result.send method} }" if result.send method
    end

    [
      "window.moving_average_data = [" + result.map { |x| dump x, :moving_average }.compact.join(',') + "];",
    ].join("\n")
  end

  private

  def moving_averages
    result.each_cons(@period) do |x|
      datapoint(x.last.date).moving_average = x.map(&:weighted_average).sma
    end
  end
end
