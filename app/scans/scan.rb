module Scan
  def self.included(base)
    base.extend(ClassMethods)
  end

  def buy?
    if available?
      instance_eval &self.class.buy_block
    end
  end

  def sell?
    if available?
      instance_eval &self.class.sell_block
    end
  end

  def available?
    indicators.all? { |x| x.available? }
  end

  def indicators
    self.class.indicators
  end

  def dataset dataset
    indicators.each { |x| x.dataset dataset }
  end

  def set_date timestamp
    indicators.each { |x| x.set_date timestamp }
  end

  def js_dump
    indicators.map(&:js_dump).join("\n")
  end

  def log
    indicators.map { |x| x.current.to_h }.reduce(&:merge)
  end

  module ClassMethods
    def buy &block
      @buy_block = block
    end

    def sell &block
      @sell_block = block
    end

    def buy_block
      @buy_block
    end

    def sell_block
      @sell_block
    end

    def indicators
      @indicators ||= []
    end

    def indicator name, obj
      indicators << obj
      class_eval do
        define_method(name) { obj.current }
      end
    end
  end
end
