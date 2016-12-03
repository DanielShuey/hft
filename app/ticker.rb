class Ticker
  class << self
    def update
      Poloniex.ticker.tap { |response| File.open(filepath, 'w') { |f| f.write(response.body) } }
      @json = read
    end

    def highest_bid
      BigDecimal.new(json['BTC_XMR']['highestBid'])
    end    

    def lowest_ask
      BigDecimal.new(json['BTC_XMR']['lowestAsk'])
    end    

    private

    def json
      @json ||= read
    end

    def filepath
      File.join(Config.root, 'assets', 'response_cache', "ticker.json")
    end

    def read
      JSON.parse(IO.read(filepath))
    end
  end
end
