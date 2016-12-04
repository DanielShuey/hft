class Robot
  class << self
    attr_accessor :dataset, :currency

    def run currency
      Rufus::Scheduler.new.tap { |s| s.every('3m') { perform currency } }.join
    end

    def perform currency
      puts "Robot Scan : #{Time.now}"
      @currency = currency
      update
      scan
    end

    private

    def update
      ChartData.update currency_pair
      Balance.update
      Ticker.update
    end

    def scan
      PoloniexSimple.new.tap do |x|
        x.dataset ChartData.read(currency_pair)

        buy  if buying?  && x.buy?
        sell if selling? && x.sell?

        history(
          x.log.merge({ 
            :btc         => Balance.available(:btc), 
            currency     => Balance.available(currency),
            :highest_bid => Ticker.highest_bid(currency_pair),
            :lowest_ask  => Ticker.lowest_ask(currency_pair)
          }).to_json
        )
      end
    end

    def buy
      puts "Robot Buy"
      puts Poloniex.buy currency_pair: currency_pair, rate: Ticker.lowest_ask(currency_pair), amount: Balance.available(:btc) * (1/Ticker.lowest_ask(currency_pair))
    end

    def sell
      puts "Robot Sell"
      puts Poloniex.sell currency_pair: currency_pair, rate: Ticker.highest_bid(currency_pair), amount: Balance.available(@currency)
    end

    def currency_pair
      "BTC_#{currency.to_s.upcase}"
    end

    def buying?
      Balance.available(:btc) > 0
    end

    def selling?
      Balance.available(currency) > 0
    end
  end
end
