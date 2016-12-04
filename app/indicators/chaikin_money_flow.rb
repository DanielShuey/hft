class ChaikinMoneyFlow
  include Indicator

  attributes *%i(money_flow_multiplier volume_for_period money_flow_volume cmf)

  dataset do
    money_flow_multiplier
    volume_for_period
    money_flow_volume
    cmf
  end

  def initialize
    @period = 20
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
      "window.cmf_data = [" + result.map { |x| dump x, :cmf }.compact.join(',') + "];",
    ].join("\n")
  end

  private

  def money_flow_multiplier
    result.each { |x| datapoint(x.date).money_flow_multiplier = ((x.close - x.low) - (x.high - x.close)) / (x.high - x.low) }
  end

  def volume_for_period
    result.each_cons(@period) do |x|
      datapoint(x.last.date).volume_for_period = x.sum(&:volume)
    end
  end

  def money_flow_volume
    result.each do |x| 
      next unless x.money_flow_multiplier && x.volume_for_period
      datapoint(x.date).money_flow_volume = x.money_flow_multiplier * x.volume_for_period
    end
  end

  def cmf
    result.each_cons(@period) do |x|
      next unless x.first.money_flow_volume && x.first.volume_for_period
      datapoint(x.last.date).cmf = x.sum(&:money_flow_volume) / x.last.volume_for_period
    end
  end
end
