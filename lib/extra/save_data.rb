require "yaml/store"

require "nokogiri"
require "open-uri"
require "singleton"

module ExchangeRate
  class SaveData

    include Singleton

    attr_reader :datasource, :xmlns

    def initialize(spec_folder = "#{Dir.pwd}")
      @store = YAML::Store.new("#{spec_folder}/rates_data/data_saved")

      @datasource = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml"
      @xmlns = "http://www.ecb.int/vocabulary/2002-08-01/eurofxref"
    end


# CRUD type methods
    def create_store(file_path)
      @store = YAML::Store.new("#{Dir.pwd}/data_saved")
    end

    def read(key)
      return @store.transaction { @store[key] }
    end

    def write(key, value)
      @store.transaction do
        @store[key] = value
      end
    end

    def delete(key)
      @store.transaction do
        @store.delete(key)
      end
    end


# methods for parsing and navigating the xml data
    def get_data_and_save
      all_data = prefetch_data
      data_saved_hash = create_data_saved_hash(all_data)
      SaveData.instance.write(:data_saved, data_saved_hash)
      return data_saved_hash
    end

    def prefetch_data
      doc = Nokogiri::XML(open(@datasource))
      return doc
    end

    def create_data_saved_hash(data)
      data_saved_hash = Hash.new
      xml_cube_time = get_xml_cube_time(data)

      xml_cube_time.each do |time|
        data_saved_hash[time.at_xpath("@time").value] = create_currencies_and_rates_hash(time)
      end
      return data_saved_hash
    end

    def get_xml_cube_time(data)
      if @xmlns == nil
        xml_cube_time = data.xpath("//Cube[@time]")
        p xml_cube_time
      else
        xml_cube_time = data.xpath("//a:Cube[@time]", {"a" => @xmlns})
      end
    end

    def create_currencies_and_rates_hash(time_cube)
      currencies_and_rates_hash = Hash.new

      currencies_and_rates_hash["EUR"] = "1"
      currencies_and_rates =  time_cube.xpath("child::*")

      currencies_and_rates.each do |currency_and_rate|
        currencies_and_rates_hash[currency_and_rate.at_xpath("@currency").value] = currency_and_rate.at_xpath("@rate").value
      end
        return currencies_and_rates_hash
    end

  end
end
