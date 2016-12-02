class Poloniex
  class << self
    TEST_SECRET = '94aa9905a27b19c4d4c1a8dae9710b50e9ff452cdd386cc8c6836afe6fad8fda13a3fd04e0cbb2c2fde2a62733452727fba4f227d173110817792368eda13629'
    TEST_API_KEY = '74FVB4RQ-CRM3THOF-KCH4A1SH-M8NXNXSK'
    
    class API
      include HTTParty
      # debug_output $stdout # Debugging to Stdout
      base_uri 'https://poloniex.com/'
    end

    def nonce
      (Time.now.to_f * 1000000).to_i
    end

    def sign data
      OpenSSL::HMAC.hexdigest 'sha512', @secret, Addressable::URI.form_encode(data)
    end

    def post command, **params
      query = { command: command, nonce: nonce }.merge(params)
      API.post "/tradingApi", { body: Addressable::URI.form_encode(query), headers: { 'Key' => @api_key, 'Sign' => sign(query) } }
    end

    def get command, **params
      API.get "/public", { query: { command: command }.merge(params) }
    end

    def production_mode toggle
      if toggle
      else
        @api_key = TEST_API_KEY
        @secret = TEST_SECRET
      end
    end

    def chart_data currency_pair:, start:, period:, finish: current_time
      get 'returnChartData', { currencyPair: currency_pair, start: start, end: finish, period: get_period(period) }
    end

    def balance
      post 'returnCompleteBalances'
    end

# "currencyPair", "rate", and "amount"
    def buy

    end

    def sell

    end

    private

    def current_time
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

  production_mode false
end
