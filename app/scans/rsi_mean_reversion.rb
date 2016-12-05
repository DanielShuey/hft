class RsiMeanReversion
  def initialize
    @indicators = []
    @sma = SimpleMovingAverage.new period: 200
    @rsi = RelativeStrengthIndex.new period: 14
    @indicators += [@sma, @rsi]
  end

  def dataset dataset
    @indicators.each { |x| x.dataset dataset }
  end

  def buy?
    return unless @sma.value && @rsi.value

    #if @sma.current.weighted_average > @sma.value
      @rsi.value < 25
    #end
  end

  def sell?
    return unless @sma.value && @rsi.value

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
