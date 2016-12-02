module Balance
  def update
    Poloniex.balance.tap { |response| File.open(balance_file, 'w') { |f| f.write(response.body) } if response.ok? }
  end

  def starting_btc
    BigDecimal.new(starting['XMR']["btcValue"]) + BigDecimal.new(starting['BTC']['btcValue'])
  end

  def available_btc
    BigDecimal.new(balance['BTC']["available"])
  end

  def available_xmr
    BigDecimal.new(available['XMR']["available"])
  end

  def estimated_btc
    BigDecimal.new(balance['XMR']["btcValue"]) + BigDecimal.new(balance['BTC']['btcValue'])
  end
  
  def estimated_profit
    estimated_btc - starting_btc
  end

  def estimated_gain
    ((estimated_btc - starting_btc) / starting_btc) * 100
  end

  private

  def balance_file
    IO.read(File.join(Config.root, 'assets', 'response_cache', 'balance.json'))
  end

  def starting_file
    IO.read(File.join(Config.root, 'assets', 'response_cache', 'starting_balance.json'))
  end

  def balance
    @balance ||= JSON.parse(balance_file)
  end

  def starting
    @starting ||= JSON.parse(starting_file)
  end
end
