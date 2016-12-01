module Indicator
  attr_reader :result, :start_date, :current, :currency_a, :currency_b

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_reader :datapoint_class, :dataset_block
  
    def attributes *args
      if args.length > 0
        class_eval do
          @datapoint_class = Class.new(::Ohlc) do
            attributes *args
          end
        end
        @attributes = *args
      end

      @attributes
    end

    def dataset &block
      @dataset_block = block
    end
  end

  def dataset dataset
    @result = dataset.map { |set| self.class.datapoint_class.new(set.context) }
    instance_eval(&self.class.dataset_block)
    @start_date = find_start_date
  end

  def datapoint timestamp
    result.find { |x| x.date == timestamp }
  end

  def set_date timestamp
    @current = datapoint(timestamp)
  end

  def set_balance a, b
    @currency_a = a
    @currency_b = b
  end

  def buying?
    @currency_a >= @currency_b
  end

  def selling?
    @currency_a <= @currency_b
  end

  private

  def find_start_date
    result.each do |datapoint|
      return datapoint.date if self.class.attributes.map{ |x| datapoint.send x }.compact.length == self.class.attributes.length
    end
  end
end
