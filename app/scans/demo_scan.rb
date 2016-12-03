class DemoScan
  def initialize
    @indicators = []
    @ema = Ema.new
    @pressure = Pressure.new
    @stoch_rsi = StochRsi.new
    @indicators += [@ema, @pressure, @stoch_rsi]
  end

  def dataset dataset
    @indicators.each { |x| x.dataset dataset }
  end

  def buy?
    @pressure.uptrend? && !@stoch_rsi.overbought? && !@ema.downtrend?
  end

  def sell?
    @pressure.downtrend? 
  end

  def set_date timestamp
    @indicators.each { |x| x.set_date timestamp }
  end

  def js_dump
    @indicators.map(&:js_dump).join("\n")
  end
end
