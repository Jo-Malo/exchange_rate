module ExchangeRate
  class Error < StandardError

    def initialize(data_inputted)
      super("#{data_inputted} was not found")
    end
  end

end
