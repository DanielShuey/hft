class Scan
  attr_accessor :indicators, :pressure

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
    if buying?
      @pressure.uptrend?
    end
  end

  def sell?
    if selling?
      @pressure.downtrend?
    end
  end

  def buying?
    @currency_a >= @currency_b
  end

  def selling?
    @currency_a <= @currency_b
  end

  def set_balance currency_a, currency_b
    @currency_a = currency_a
    @currency_b = currency_b
    @indicators.each { |x| x.set_balance currency_a, currency_b }
  end

  def set_date timestamp
    @indicators.each { |x| x.set_date timestamp }
  end

  def js_dump
    @indicators.map(&:js_dump).join("\n")
  end
end
