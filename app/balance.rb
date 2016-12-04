class Balance
  class << self
    def update
      Poloniex.balance.tap { |response| File.open(balance_filename, 'w') { |f| f.write(response.body) } if response.ok? }
      @balance = JSON.parse(balance_file)
    end

    def starting_btc
      BigDecimal.new(starting[Config.currency.upcase]["btcValue"]) + BigDecimal.new(starting['BTC']['btcValue'])
    end

    def available currency
      BigDecimal.new(balance[currency.to_s.upcase]["available"])
    end

    def estimated_btc
      BigDecimal.new(balance[Config.currency.upcase]["btcValue"]) + BigDecimal.new(balance['BTC']['btcValue'])
    end
    
    def estimated_profit
      estimated_btc - starting_btc
    end

    def estimated_gain
      ((estimated_btc - starting_btc) / starting_btc) * 100
    end

    private

    def balance_filename
      File.join(Config.root, 'temp', 'responses', 'balance.json')
    end

    def balance_file
      IO.read(balance_filename)
    end

    def starting_file
      IO.read(File.join(Config.root, 'assets', 'data', 'starting_balance.json'))
    end

    def balance
      @balance ||= JSON.parse(balance_file)
    end

    def starting
      @starting ||= JSON.parse(starting_file)
    end
  end
end
