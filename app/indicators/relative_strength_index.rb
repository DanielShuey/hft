class RelativeStrengthIndex
  include Indicator

  attributes *%i(rsi change gain loss average_gain average_loss)

  dataset do
    changes
    gains
    losses
    average_gains
    average_losses
    rsi
  end

  def initialize period:
    @period = period
  end

  def value
    current.rsi
  end

  def js_dump
    def dump result, method
      "{ x: new Date(#{result.date * 1000}), y: #{result.send method} }" if result.send method
    end

    [
      "window.rsi_data = [" + result.map { |x| (dump x, :rsi) }.compact.join(',') + "];"
    ].join("\n")
  end

  private

  def changes
    result.each_cons(2) do |left, right|
      datapoint(right.date).change = right.weighted_average - left.weighted_average
    end
  end

  def gains
    result.each do |x|
      next unless x.change
      datapoint(x.date).gain = x.change > 0 ? x.change.abs : 0 
    end
  end

  def losses
    result.each do |x|
      next unless x.change
      datapoint(x.date).loss = x.change < 0 ? x.change.abs : 0
    end
  end

  def average_gains
    result.each_cons(@period) do |x|
      next unless x.first.gain
      datapoint(x.last.date).average_gain = x.map(&:gain).sum / @period
    end
  end

  def average_losses
    result.each_cons(@period) do |x|
      next unless x.first.loss
      datapoint(x.last.date).average_loss = x.map(&:loss).sum / @period
    end
  end

  def rsi
    result.each do |x|
      next unless x.average_gain && x.average_loss

      if x.average_loss == 0
        datapoint(x.date).rsi = 100
      elsif x.average_gain == 0
        datapoint(x.date).rsi = 0
      else
        rs = x.average_gain / x.average_loss
        datapoint(x.date).rsi = 100 - (100 / (1 + rs))
      end

    end
  end
end
