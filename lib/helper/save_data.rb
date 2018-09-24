require "yaml/store"

require "nokogiri"
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
    def prefetch_data
      doc = Nokogiri::XML(open(@datasource))
      return doc
    end

    def create_hash(data)
      data_saved_hash = Hash.new
      xml_cube_time = get_xml_date(data)

      xml_cube_time.each do |time|
        data_saved_hash[time.at_xpath("@time").value] = create_rates_hash(time)
      end
      return data_saved_hash
    end

    def get_xml_date(data)
      xml_cube_time = data.xpath("//ns:Cube[@time]", {"ns" => @xmlns})
    end

    def save_data_away
      all_data = prefetch_data
      data_saved_hash = create_hash(all_data)
      SaveData.instance.write(:data_saved, data_saved_hash)
      return data_saved_hash
    end

    def create_rates_hash(cube_time)
      node_values = Hash.new

      node_values["***"] = "#.#"
      currency_and_rate =  cube_time.xpath("child::*")

      currency_and_rate.each do |currency_and_rate|
        node_values[currency_and_rate.at_xpath("@currency").value] = currency_and_rate.at_xpath("@rate").value
      end
        return node_values
    end

  end
end
