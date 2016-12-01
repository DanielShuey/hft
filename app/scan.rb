class Scan
  attr_accessor :dataset, :indicators, :dema, :stoch_rsi

  def initialize
    @indicators = []
    @stoch_rsi = StochRsi.new
    @dema = Dema.new
    @indicators += [stoch_rsi, dema]
  end

  def dataset dataset
    @indicators.each { |x| x.dataset dataset }
  end

  def buy?
    
  end

  def sell?

  end

  def set_balance currency_a, currency_b
    @indicators.each { |x| x.set_balance currency_a, currency_b }
  end

  def set_date timestamp
    @indicators.each { |x| x.set_date timestamp }
  end

  def js_dump
    @indicators.map(&:js_dump).join("\n")
  end
end
