class RsiMeanReversion 
  include Scan

  indicators(
    RelativeStrengthIndex.new(period: 14),
    ExponentialMovingAverage.new(long: 1000, short: 250, double: true)
  )

  buy do
    if exponential_moving_average.trend == :up
      relative_strength_index.rsi < 25
    end
  end

  sell do
    relative_strength_index.rsi > 55
  end
end
