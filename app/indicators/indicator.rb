module Indicator
  attr_reader :result, :current

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

  def available?
    self.class.attributes.map { |x| current.send x }.compact.length == self.class.attributes.length
  end

  def dataset dataset
    @result = dataset.map { |set| self.class.datapoint_class.new(set.context) }
    instance_eval(&self.class.dataset_block) if self.class.dataset_block
    set_date dataset.last.date
  end

  def datapoint timestamp
    result.find { |x| x.date == timestamp }
  end

  def set_date timestamp
    @current = datapoint(timestamp)
  end

  def js_dump
  end
end
