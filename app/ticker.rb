class Ticker
  class << self
    def update
      Poloniex.ticker.tap { |response| File.open(filepath, 'w') { |f| f.write(response.body) } }
      @json = read
    end

    def highest_bid
      BigDecimal.new(json[Config.currency_pair]['highestBid'])
    end    

    def lowest_ask
      BigDecimal.new(json[Config.currency_pair]['lowestAsk'])
    end    

    private

    def json
      @json ||= read
    end

    def filepath
      File.join(Config.root, 'temp', 'responses', "ticker.json")
    end

    def read
      JSON.parse(IO.read(filepath))
    end
  end
end
