class Poloniex
  class << self
    class API
      include HTTParty
      # debug_output $stdout # Debugging to Stdout
      base_uri 'https://poloniex.com/'
    end

    def chart_data currency_pair: Config.currency_pair, start:, period:, finish: current_time
      get 'returnChartData', { currencyPair: currency_pair, start: start, end: finish, period: get_period(period) }
    end
  
    def ticker
      get 'returnTicker'
    end

    def balance
      post 'returnCompleteBalances'
    end

    def buy rate:, amount:
      post 'buy', currencyPair: Config.currency_pair, rate: rate, amount: amount, immediateOrCancel: 1
    end

    def sell rate:, amount:
      post 'sell', currencyPair: Config.currency_pair, rate: rate, amount: amount, immediateOrCancel: 1
    end

    private

    def post command, **params
      query = { command: command, nonce: nonce }.merge(params)
      API.post "/tradingApi", { body: Addressable::URI.form_encode(query), headers: { 'Key' => Config.api_key, 'Sign' => sign(query) } }
    end

    def get command, **params
      API.get "/public", { query: { command: command }.merge(params) }
    end

    def nonce
      (Time.now.to_f * 1000000).to_i
    end

    def sign data
      OpenSSL::HMAC.hexdigest 'sha512', Config.secret, Addressable::URI.form_encode(data)
    end

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
end
