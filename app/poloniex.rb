class Poloniex
  class << self
    SECRET = '94aa9905a27b19c4d4c1a8dae9710b50e9ff452cdd386cc8c6836afe6fad8fda13a3fd04e0cbb2c2fde2a62733452727fba4f227d173110817792368eda13629'
    API_KEY = '74FVB4RQ-CRM3THOF-KCH4A1SH-M8NXNXSK'

    def post command, **params
      nonce = (Time.now.to_f * 1000000).to_i
      HTTParty.post("https://poloniex.com/tradingApi", { query: { command: command }.merge(params) })
    end

    def get command, **params
      HTTParty.get("https://poloniex.com/public", { query: { command: command }.merge(params) })
    end

    def chart_data currency_pair:, start:, finish:, period:
      get 'returnChartData', { currencyPair: currency_pair, start: start, end: finish, period: period }
    end

    def available_balance
      post 'returnBalances'
    end

    def complete_balance

    end

    private

    def hours_to_timestamp hours
      (DateTime.now - (hours.to_f/24.to_f)).to_time.to_i
    end

    def current_timestamp
      Time.now.getutc.to_i
    end

    def get_period arg
      periods = {
        '5mins' => 300,
        '15mins' => 900,
        '30mins' => 1800,
        '2hours' => 7200,
        '4hours' => 14400,
        '1day' => 86400,
      } 
      return periods[arg]
    end
  end
end
