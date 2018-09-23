require "yaml/store"
######## for parsing XML data from api
require "nokogiri"
require "open-uri"
require "singleton"
########

module ExchangeRate
  class SaveData
    ######
    include Singleton

    attr_reader :endpoint, :xmlns
    #######
    def initialize(spec_folder = "#{Dir.pwd}")
      @store = YAML::Store.new("#{spec_folder}/rates_data/data_saved")
      #######
      @endpoint = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml"
      @xmlns = "http://www.ecb.int/vocabulary/2002-08-01/eurofxref"
      #######
    end



    def set_store(file_path)
      @store = YAML::Store.new("#{Dir.pwd}/data_saved")
    end

    def write(key, value)
      @store.transaction do
        @store[key] = value
      end
    end

    def read(key)
      return @store.transaction { @store[key] }
    end

    def delete(key)
      @store.transaction do
        @store.delete(key)
      end
    end

    ######################################################################
    # methods for parsing the xml data

    def set_data_source(new_endpoint, new_xmlns = nil)
      @endpoint = new_endpoint
      @xmlns = new_xmlns

      SaveData.instance.delete(:data_saved)
    end

    def get_data_and_save
      all_data = fetch_data
      data_saved_hash = create_data_saved_hash(all_data)

    # if data_saved_hash.empty?
      #   raise EmptyFxDataHashError.new
      # else
        SaveData.instance.write(:data_saved, data_saved_hash)
      return data_saved_hash
      # end
    end

    # private

    def fetch_data
      doc = Nokogiri::XML(open(@endpoint))
      return doc
    end

    def create_data_saved_hash(data)

      data_saved_hash = Hash.new

      time_cubes = extract_time_cubes(data)

      time_cubes.each do |cube|
        data_saved_hash[cube.at_xpath("@time").value] = create_currencies_and_rates_hash(cube)
      end
      return data_saved_hash
    end

    def extract_time_cubes(data)
      if @xmlns == nil
        time_cubes = data.xpath("//Cube[@time]")
        p time_cubes
      else
        time_cubes = data.xpath("//a:Cube[@time]", {"a" => @xmlns})
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
