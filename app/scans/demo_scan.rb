class DemoScan
  def initialize
    @indicators = []
    @ema = Ema.new
    @pressure = Pressure.new
    @stoch_rsi = StochRsi.new
    @volume_ratio = VolumeRatio.new
    @indicators += [@ema, @pressure, @stoch_rsi, @volume_ratio]
  end

  def dataset dataset
    @indicators.each { |x| x.dataset dataset }
  end

  def buy?
    @pressure.uptrend?
  end

  def sell?
    @ema.negative_crossover? || @stoch_rsi.overbought?
  end

  def set_date timestamp
    @indicators.each { |x| x.set_date timestamp }
  end

  def js_dump
    @indicators.map(&:js_dump).join("\n")
  end
end
