class PoloniexSimple
  def initialize
    @indicators = []
    @ema = Ema.new
    @pressure = Pressure.new
    @indicators += [@ema, @pressure]
  end

  def dataset dataset
    @indicators.each { |x| x.dataset dataset }
  end

  def buy?
    @pressure.uptrend? && !@ema.downtrend?
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

  def log
    @indicators.map { |x| x.current.to_h }.reduce(&:merge)
  end
end
