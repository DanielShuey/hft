class ChartData
  class << self
    def update
      Poloniex.chart_data(currency_pair: Config.currency_pair, start: backtrack(336), period: '15mins').tap do |response|
        File.open(File.join(Config.root, 'temp', 'responses', "chart_#{Config.currency_pair}.json"), 'w') { |f| f.write(response.body) }
      end
    end
   
    def update_historic currency_pair:, rewind: 24, period: '5mins'
      Poloniex.chart_data(currency_pair: currency_pair, start: backtrack(rewind), period: period).tap do |response|
        File.open(File.join(Config.root, 'assets', 'history', "#{currency_pair}-#{rewind}hrs-#{period}.json"), 'w') { |f| f.write(response.body) }
      end

    end

    def historic filename
      create_from_json IO.read(File.join(Config.root, 'assets', 'history', "#{filename}.json"))
    end

    def read
      create_from_json IO.read(File.join(Config.root, 'temp', 'responses', "chart_#{Config.currency_pair}.json"))
    end

    private

    def create_from_json json
      JSON.parse(json).map { |x| Ohlc.new(**x.map { |k, v| [k.underscore.to_sym, v] }.to_h) }
    end  

    def backtrack hours
      (DateTime.now - (hours.to_f/24.to_f)).to_time.to_i
    end
  end
end
