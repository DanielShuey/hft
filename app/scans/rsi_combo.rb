class RsiCombo
  def initialize
    @indicators = []
    @pressure = Pressure.new period: 14
    @rsi = RelativeStrengthIndex.new period: 14
    @indicators += [@pressure, @rsi]
  end

  def dataset dataset
    @indicators.each { |x| x.dataset dataset }
  end

  def buy?
    return unless @pressure.value && @rsi.value
    
    @rsi.value < 25 || @pressure.value > 0.5
  end

  def sell?
    return unless @pressure.value && @rsi.value

    @rsi.value > 55
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
