class Strategy
  attr_accessor :dataset, :strategies, :dema, :stoch_rsi

  def initialize
    strategies = []
    @stoch_rsi = StochRsi.new
    @strategies += [dema, stoch_rsi]
  end

  def dataset dataset
    @strategies.each { |x| x.dataset dataset }
  end

  def buy?
    
  end

  def sell?

  end

  def set_date timestamp
    @strategies.each { |x| x.set_date timestamp }
  end
end
