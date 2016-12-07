class RsiCombo
  include Scan

  attr_accessor :type

  indicators(
    RelativeStrengthIndex.new(period: 14),
    ExponentialMovingAverage.new(long: 1000, short: 250, double: true),
    Pressure.new(period: 30)
  )

  buy do
    if exponential_moving_average.trend == :up
      if relative_strength_index.rsi < 25
        @type = :rsi
        true
      elsif pressure.normalized_pressure >= 0.7
        @type = :pressure
        true
      end
    end
  end

  sell do
    if @type == :rsi
      relative_strength_index.rsi > 55
    elsif @type == :pressure
      pressure.normalized_pressure <= -0.7
    end
  end
end
