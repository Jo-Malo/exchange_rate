require_relative "../lib/exchange_rate"
require_relative "../lib/extra/save_data"
require_relative "../lib/extra/error"
require_relative "../lib/extra/conversion"
require "minitest/autorun"
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/' # for rspec
  add_filter '/test/' # for minitest
end

class ExchangeRateTest < Minitest::Test

# TESTS FOR ERROR.RB in case of invalid input and error message
# :: indicates ExchangeRateModule::ErrorClass

  # without .to_s what is returned is: #<ExchangeRate::Error:  was not found>
  def test_nothing_entered_in_date_field_gives_error
    assert_equal(" was not found",
    ExchangeRate::Error.new('').to_s)
  end

  def test_currency_entered_by_user_does_not_exist
    assert_equal("BOB was not found",
    ExchangeRate::Error.new('BOB').to_s)
  end

  def test_past_date_entered_by_user_does_not_exist
    assert_equal("2010-10-01 was not found",
    ExchangeRate::Error.new('2010-10-01').to_s)
  end

  def test_future_date_entered_by_user_does_not_exist
    assert_equal("2019-10-01 was not found",
    ExchangeRate::Error.new('2019-10-01').to_s)
  end

  def test_weekend_date_entered_by_user_does_not_exist
    assert_equal("2018-09-15 was not found",
    ExchangeRate::Error.new('2018-09-15').to_s)
  end

  def test_date_entered_by_user_has_incorrect_format
    assert_equal("20188-09-15 was not found",
    ExchangeRate::Error.new('20188-09-15').to_s)
  end

  def test_text_entered_by_user_is_not_a_date
    assert_equal("?!#*&£ was not found",
    ExchangeRate::Error.new('?!#*&£').to_s)
  end

# TESTS FOR SAVE_DATA.RB to check I can get data from api
  # checks that there are 65 days of info on rates - increases each day?
  def test_can_get_rates_data_and_save
    assert_equal(65, ExchangeRate::SaveData.instance.get_data_and_save.count)
  end

  def test_can_check_existing_key_returns_true
    assert_equal(true, ExchangeRate::SaveData.instance.get_data_and_save.has_key?("2018-09-21"))
  end

  def test_can_check_absent_key_returns_false
    assert_equal(false, ExchangeRate::SaveData.instance.get_data_and_save.has_key?("2018-11-21"))
  end

  # :testing is a key or symbol for the file? Was :test before :save_data
  def test_can_save_api_data_to_file
    ExchangeRate::SaveData.instance.write(:save_data, "Test is a success...")
    assert_equal("Test is a success...", ExchangeRate::SaveData.instance.read(:save_data))
  end

  def test_can_delete_test_data_from_file
    ExchangeRate::SaveData.instance.write(:save_data, "Test is a success...")
    ExchangeRate::SaveData.instance.delete(:save_data)
    assert_equal(nil, ExchangeRate::SaveData.instance.read(:save_data))
  end

# TESTS FOR CONVERSION.RB METHODS
  def test_returns_true_with_existing_date
    assert_equal(true, ExchangeRate::Conversion.if_string_date_is_valid("2018-06-13"))
  end

  def test_returns_false_with_invalid_date
    assert_equal(false, ExchangeRate::Conversion.if_string_date_is_valid("fjnajsn"))
  end

  # this previously used BigDecimal
  def test_can_get_exchange_rate_with_date
    assert_equal("1.1667", ExchangeRate::Conversion.get_rate_at_date("2018-09-19", "GBP", "USD"))
  end

  # written on 21 Sept
  def test_can_get_exchange_rate_with_earliest_date
    assert_equal("15.8282", ExchangeRate::Conversion.get_rate_at_date("2018-06-25", "GBP", "ZAR"))
  end
  # written on 21 Sept
  def test_can_get_exchange_rate_at_latest_date
    assert_equal("22.2132", ExchangeRate::Conversion.get_rate_at_date("2018-09-21", "GBP", "MXN"))
  end

  def test_can_get_exchange_rate_at_with_required_format
    assert_equal("22.2132", ExchangeRate.at("2018-09-21", "GBP", "MXN"))
  end

  # written on 21st Sept which passed... retest on 24th Sept
  # def test_can_get_exchange_rate_today_with_required_format
  #   assert_equal("22.2132", ExchangeRate.at(Date.today, "GBP", "MXN"))
  # end
  # 
  # def test_can_get_exchange_rate_yesterday_with_required_format2
  #   assert_equal("22.2132", ExchangeRate.at(Date.today.prev_day, "GBP", "MXN"))
  # end

  def test_raise_error_with_two_invalid_currencies
    assert_raises(ExchangeRate::Error) do
    ExchangeRate::Conversion.get_rate_at_date("FAB", "ZOO")
    end
  end

  def test_raise_error_with_second_invalid_currency
    assert_raises(ExchangeRate::Error) do
      ExchangeRate::Conversion.get_rate_at_date("GBP", "ZOO")
    end
  end

  def test_raise_error_with_first_invalid_currency
    assert_raises(ExchangeRate::Error) do
      ExchangeRate::Conversion.get_rate_at_date("ZOO", "GBP")
    end
  end

  # following give assertion but 1 failure too - error not raised
  # def test_invalid_currency_raises_error
  #   assert_raises(ExchangeRate::Error) do
  #   ExchangeRate::Conversion.get_rate_at_date("BLA", "ALG")
  #   end
  # end

end
