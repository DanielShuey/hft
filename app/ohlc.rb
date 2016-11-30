class Ohlc
  def initialize **args
    args.each_pair { |k, v| send "#{k}=", v }
  end

  def self.attributes *attributes
    attr_accessor *attributes
    @attributes ||= []
    @attributes += attributes
  end

  def self.from_json json
    JSON.parse(json).map { |x| Ohlc.new(**x.map { |k, v| [k.underscore.to_sym, v] }.to_h) }
  end

  def context
    self.class.attributes.map do |attribute|
      [ attribute, instance_variable_get("@#{attribute}") ]
    end.to_h
  end

  attributes *%i(open high low close volume quote_volume weighted_average date)
end
