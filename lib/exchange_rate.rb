require_relative "extra/save_data"
require_relative "extra/error"
require_relative "extra/conversion"
require "open-uri"

module ExchangeRate

  def self.create_store(file_path)
    SaveData.instance.create_store(file_path)
  end

  def self.set_data_source(new_datasource, new_xmlns = nil)
    SaveData.instance.set_data_source(new_datasource, new_xmlns)
  end

  def self.at(today = Date.today, from_currency, to_currency)
    return Conversion.get_rate_at_date(today, from_currency, to_currency)
  end

  def self.at(date_yesterday = Date.today.prev_day, from_currency, to_currency)
    return Conversion.get_rate_at_date(date_yesterday, from_currency, to_currency)
  end

end
