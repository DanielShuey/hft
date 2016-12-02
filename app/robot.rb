class Robot
  include Balance

  def dataset
    @dataset ||= Ohlc.from_json(IO.read(File.join(Config.root, 'assets', 'response_cache', "chart.json")))
  end

  def start_scan
    @scan = PoloniexSimple.new
    @scan.dataset dataset
    @scan.set_date dataset.last.date
  end

  def update_balance
    file = File.join(Config.root, 'assets', 'response_cache', 'available_balance.json')

    Poloniex.available_balance.tap do |response|
      File.open(file, 'w') { |f| f.write(response.body) } if response.ok?
    end

    JSON.parse(file).tap do |response|
      @xmr = response['XMR']
      @btc = response['BTC']
    end
  end

  def buy

  end

  def sell

  end

  def perform
    update_balance

    dataset.each do |x|
      set_date x.date

      buy  if scan.buy?
      sell if scan.sell?
    end

    sell if currency_other > 0
  end
end
