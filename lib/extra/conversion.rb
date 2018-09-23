module ExchangeRate
  class Conversion
    # bunch of nested if statements to check all are OK
    def self.get_rate_at_date(date = Date.today, from_currency, to_currency)
      # Check if date is valid and saves away
      if if_string_date_is_valid(date)

        # Read data from saved data or fetch it from the source, using SaveData class and :data_saved file?
        # follows structure of if condition ? true_expression : false_expression. If data is saved in data_saved then save it, but if not, fetch and save it!
        data_saved = SaveData.instance.read(:data_saved) ? SaveData.instance.read(:data_saved) : SaveData.instance.get_data_and_save
        #get_data_and_Save needs to be tested!

        cal_date_as_string = date.to_s

        # If date is not in the saved date hash then you get an error
      if !data_saved[cal_date_as_string]

        # If the date_is_within_range (method below) and it's the prev_day, check for the rate at the nearest past date
        # .prev_day is existing method in Ruby e.g. date-1
        # and rate_at_date nested if statement at top, so like a filter
      if date_is_within_range(data_saved, cal_date_as_string)
        day_before = Date.parse(cal_date_as_string).yesterday
        return rate_at_date(day_before, from_currency, to_currency)
      else
        raise Error.new(cal_date_as_string)
      end

      #   Check if currencies are valid
      else
        [from_currency, to_currency].each do
          raise NotFoundError.new(curr) if !data_saved[cal_date_as_string] || !data_saved[cal_date_as_string]
        end
      end

      # Calculate exchange rate with bigdecimal which gives floating point no. but I don't think that calculation is necessary so have removed bigdecimal below
      # it takes your target currency and divides it by base currency
    #   target_exchange_rate = BigDecimal(data_saved[cal_date_as_string][to_currency]) *   BigDecimal(data_saved[cal_date_as_string][from_currency])
    #     return target_exchange_rate
    #   else
    #     return Error.new
    #   end
    # end

    target_exchange_rate = (data_saved[cal_date_as_string][to_currency])
        return target_exchange_rate
      else
        return Error.new
      end
    end

# helper methods

    def self.if_string_date_is_valid(date)
      Date.parse(date.to_s)
      return true
    rescue StandardError
      return false
    end

    #the keys used below are the dates - see data_saved file
    #if date is within range, it returns true
    # def self.date_is_within_range(data_saved, date)
    #   earliest_date = Date.parse(data_saved.keys.min)
    #   latest_date = Date.parse(data_saved.keys.max)
    #   return Date.parse(date) < latest_date && Date.parse(date) > earliest_date
    #   end

    #was failing so copy of original above
    def self.date_is_within_range(data_saved, date)
      earliest_date = Date.parse(data_saved.keys.min)
      latest_date = Date.parse(data_saved.keys.max)
      if Date.parse(date) < latest_date && Date.parse(date) > earliest_date
        return true
      end
    end

  end
end
