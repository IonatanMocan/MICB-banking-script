class Transactions
  attr_accessor :date, :description, :amount, :currency

  def initialize(args)
    @date        = args[:date]
    @description = args[:description]
    @amount      = args[:amount]
    @currency    = args[:currency]
  end
end
