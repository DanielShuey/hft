class Ohlc < Struct.new :open, :high, :low, :close, :volume, :quote_volume, :weighted_average, :date
  def initialize **args
    args.each_pair { |k, v| send "#{k}=", v }
  end

  def self.from_json json
    JSON.parse(json).map { |x| Ohlc.new(**x.map { |k, v| [k.underscore.to_sym, v] }.to_h) }
  end
end
