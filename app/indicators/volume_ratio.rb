class VolumeRatio
  include Indicator

  attributes *%i(volume_ratio)

  dataset do
    volume_ratios
  end

  def initialize
    @period = 30
  end

  def above_threshold?
    current.volume_ratio if current.volume_ratio
  end

  def js_dump
    def dump result, method
      "{ x: new Date(#{result.date * 1000}), y: #{result.send method} }" if result.send method
    end

    [
      "window.volume_ratio_data = [" + result.map { |x| dump x, :volume_ratio }.compact.join(',') + "];",
    ].join("\n")
  end

  private

  def volume_ratios
    result.each_cons(@period) do |x|
      datapoint(x.last.date).volume_ratio = (x[-3..-1].map(&:volume).ema / x.map(&:volume).max)
    end
  end
end
