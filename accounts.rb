class Account
  attr_accessor :name, :balance, :currency, :nature, :transactions

  def initialize(args = {})
    @name         = args[:name]
    @balance      = args[:balance]
    @currency     = args[:currency]
    @nature       = args[:nature]
    @transactions = []
  end
end
