require_relative "helper/save_data"
require_relative "helper/error"
require_relative "helper/conversion"
require "open-uri"

module ExchangeRate

  def self.at(today = Date.today, from_currency, to_currency)
    return Conversion.get_rate_at_date(today, from_currency, to_currency)
  end

  def self.at(date_yesterday = Date.today.prev_day, from_currency, to_currency)
    return Conversion.get_rate_at_date(date_yesterday, from_currency, to_currency)
  end

end
