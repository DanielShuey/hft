class RsiCombo 
  include Scan

  indicators(
    RelativeStrengthIndex.new(period: 14),
    ExponentialMovingAverage.new(long: 1000, short: 250, double: false)
  )

  def buy?
    return unless relative_strength_index.rsi && exponential_moving_average.trend

    if exponential_moving_average.trend == :up
      return relative_strength_index.rsi < 25
    end
  end

  def sell?
    return unless relative_strength_index.rsi && exponential_moving_average.trend

    relative_strength_index.rsi > 55
  end
end
