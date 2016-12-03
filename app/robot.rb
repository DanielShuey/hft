class Robot
  class << self
    def run currency
      Rufus::Scheduler.new.tap { |s| s.every('3m') { perform currency } }.join
    end

    private

    def perform currency
      puts "Robot Scan : #{Time.now}"
      @currency = currency
      update
      scan
    end

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
      puts Poloniex.buy currency_pair: 'BTC_XMR', rate: Ticker.lowest_ask, amount: Balance.available_btc * (1/Ticker.lowest_ask)
    end

    def sell
      Ticker.update
      puts "Robot Sell"
      puts Poloniex.sell currency_pair: 'BTC_XMR', rate: Ticker.highest_bid, amount: Balance.available_xmr
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
