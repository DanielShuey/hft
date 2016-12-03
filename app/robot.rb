class Robot
  class << self
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

    def dataset
      @dataset ||= ChartData.read currency_pair
    end

    def update
      ChartData.update currency_pair
      Balance.update
    end

    def scan
      PoloniexSimple.new.tap do |x|
        x.dataset ChartData.read currency_pair
        x.set_date dataset.last.date

        buy  if buying?  && x.buy?
        sell if selling? && x.sell?
      end
    end

    def buy
      Ticker.update
      puts "Robot Buy"
      puts Poloniex.buy currency_pair: currency_pair, rate: Ticker.lowest_ask(currency_pair), amount: Balance.available(:btc) * (1/Ticker.lowest_ask(currency_pair))
    end

    def sell
      Ticker.update
      puts "Robot Sell"
      puts Poloniex.sell currency_pair: currency_pair, rate: Ticker.highest_bid(currency_pair), amount: Balance.available(@currency)
    end

    def currency_pair
      "BTC_#{@currency.to_s.upcase}"
    end

    def buying?
      Balance.available(:btc) > 0
    end

    def selling?
      Balance.available(@currency) > 0
    end
  end
end
