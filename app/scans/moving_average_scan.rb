class MovingAverageScan
  include Scan

  indicator :threshold, SimpleMovingAverage.new(period: 672)
  indicator :ema,       ExponentialMovingAverage.new(long: 200, short: 50, double: true)

  buy do
    ema.short > threshold.moving_average && ema.trend == :up
  end

  sell do
    ema.trend == :down
  end
end
