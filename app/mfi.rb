class Mfi
  include Indicator

  attr_reader :result, :start_date, :current

  attributes *%i(typical_price direction raw_money_flow positive_flow negative_flow money_flow_ratio mfi)

  dataset do
    typical_price
    direction
    raw_money_flow
    positive_flow
    negative_flow
    money_flow_ratio
    money_flow_index
  end

  def initialize
    @period = 14
  end

  def overbought?
    current.mfi > 80 if current.mfi
  end

  def oversold?
    current.mfi < 20 if current.mfi
  end

  def js_dump
    def dump result, method
      "{ x: new Date(#{result.date * 1000}), y: #{result.send method} }" if result.send method
    end

    [
      "window.mfi_data = [" + result.map { |x| (dump x, :mfi) }.compact.join(',') + "];"
    ].join("\n")
  end

  private

  def typical_price
    result.each { |x| datapoint(x.date).typical_price = (x.high + x.low + x.close) / 3 }
  end

  def direction
    result.each_cons(2) do |left, right|
      datapoint(right.date).direction = right.typical_price - left.typical_price >= 0 ? 1 : -1
    end
  end

  def raw_money_flow
    result.each { |x| datapoint(x.date).raw_money_flow = x.typical_price * x.volume }
  end

  def positive_flow
    result.each do |x|
      next unless x.raw_money_flow && x.direction
      datapoint(x.date).positive_flow = x.direction == 1 ? x.raw_money_flow : 1
    end
  end

  def negative_flow
    result.each do |x|
      next unless x.raw_money_flow && x.direction
      datapoint(x.date).negative_flow = x.direction == -1 ? x.raw_money_flow : 1
    end
  end

  def money_flow_ratio
    result.each_cons(@period) do |x|
      next unless x.first.positive_flow
      datapoint(x.last.date).money_flow_ratio = x.sum(&:positive_flow) / x.sum(&:negative_flow)
    end
  end

  def money_flow_index
    result.each do |x|
      next unless x.money_flow_ratio
      datapoint(x.date).mfi = 100 - (100/(1 + x.money_flow_ratio))
    end
  end
end
