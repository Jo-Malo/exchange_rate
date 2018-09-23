module ExchangeRate
  class Error < StandardError
    #creating custom exceptions
    #standard error is a super class. All ruby exceptions descendants of Exception class
    # use super and pass data_inputted as argument
    def initialize(data_inputted)
      super("#{data_inputted} was not found")
    end
  end

end
