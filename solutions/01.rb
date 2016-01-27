EXCHANGE_RATES = {
  bgn: 1.0,
  usd: 1.7408,
  eur: 1.9557,
  gbp: 2.6415
}

def convert_to_bgn(price, currency)
  (price * EXCHANGE_RATES[currency]).round(2)
end

def compare_prices(price_a, currency_a, price_b, currency_b)
  convert_to_bgn(price_a, currency_a) <=> convert_to_bgn(price_b, currency_b)
end