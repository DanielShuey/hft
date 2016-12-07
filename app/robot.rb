class Robot
  class << self
    attr_accessor :dataset

    def run
      Rufus::Scheduler.new.tap { |s| s.every('5m') { perform } }.join
    end

    def scan
      @scan ||= MovingAverageScan.new
    end

    def perform
      puts "Robot Scan : #{Config.currency_pair} : #{scan.class.name} : #{Time.now}"
      update
      run_scan
    end

    private

    def update
      ChartData.update
      Balance.update
      Ticker.update
    end

    def run_scan
      scan.tap do |x|
        x.dataset ChartData.read

        buy  if buying?  && x.buy?
        sell if selling? && x.sell?

        history(
          x.log.merge({ 
            :btc            => Balance.available(:btc), 
            Config.currency => Balance.available(Config.currency),
            :highest_bid    => Ticker.highest_bid,
            :lowest_ask     => Ticker.lowest_ask,
            :buy            => buying?  && x.buy?,
            :sell           => selling? && x.sell?
          }).to_json
        )
      end
    end

    def buy
      puts "Robot Buy"
      puts Poloniex.buy rate: Ticker.lowest_ask, amount: Balance.available(:btc) * (1/Ticker.lowest_ask)
    end

    def sell
      puts "Robot Sell"
      puts Poloniex.sell rate: Ticker.highest_bid, amount: Balance.available(Config.currency)
    end

    def buying?
      Balance.available(:btc) > 0.001
    end

    def selling?
      (Balance.available(Config.currency) * Ticker.highest_bid) > 0.001
    end
  end
end
