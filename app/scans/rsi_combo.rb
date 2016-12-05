class RsiCombo 
  def initialize
    @indicators = []
    @sma = SimpleMovingAverage.new period: 1000
    @rsi = RelativeStrengthIndex.new period: 14
    @indicators += [@rsi, @sma]
  end

  def dataset dataset
    @indicators.each { |x| x.dataset dataset }
  end

  def buy?
    return unless @rsi.value && @sma.value

    if @sma.current.weighted_average > @sma.value
      @rsi.value < 25
    end
  end

  def sell?
    return unless @rsi.value && @sma.value

    return @rsi.value > 55
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
