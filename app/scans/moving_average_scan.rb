class MovingAverageScan
  include Scan

  indicator :threshold, SimpleMovingAverage.new(period: 1000)
  indicator :ema,       ExponentialMovingAverage.new(long: 200, short: 50, double: true)

  buy do
    if ema.long > threshold.moving_average
      ema.trend == :up
    end
  end

  sell do
    ema.trend == :down
  end
end
