module ExchangeRate
  class Conversion

# helper methods

    def self.if_string_date_is_valid(date)
      Date.parse(date.to_s)
      return true
    rescue StandardError
      return false
    end

    def self.date_chosen_has_data(data_saved, date)
      earliest_date = Date.parse(data_saved.keys.min)
      latest_date = Date.parse(data_saved.keys.max)
      if Date.parse(date) < latest_date && Date.parse(date) > earliest_date
        return true
      end
    end
#

    def self.get_rate_at_date(date = Date.today, from_currency, to_currency)
      # Check if date is valid and saves away
      if if_string_date_is_valid(date)

        data_saved = SaveData.instance.read(:data_saved) ? SaveData.instance.read(:data_saved) : SaveData.instance.save_data_away

        cal_date_as_string = date.to_s

      if !data_saved[cal_date_as_string]

      if date_chosen_has_data(data_saved, cal_date_as_string)
        day_before = Date.parse(cal_date_as_string).yesterday
        return rate_at_date(day_before, from_currency, to_currency)
      else
        raise Error.new(cal_date_as_string)
      end

      else
        [from_currency, to_currency].each do
          raise NotFoundError.new(curr) if !data_saved[cal_date_as_string] || !data_saved[cal_date_as_string]
        end
      end

      target_exchange_rate = (data_saved[cal_date_as_string][to_currency])
        return target_exchange_rate
      else
        return Error.new
      end
    end

  end
end
