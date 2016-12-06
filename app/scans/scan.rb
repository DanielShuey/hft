module Scan
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def indicators *indicators
      if indicators.length > 0
        @indicators = indicators

        class_eval do
          @indicators.each do |x|
            define_method(x.class.name.underscore) { x.current }
          end
        end
      else
        @indicators
      end
    end
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
end
