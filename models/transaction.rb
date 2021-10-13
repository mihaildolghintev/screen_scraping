require 'json'

class Transaction
  attr_accessor :date, :description, :amount, :currency, :account_name

  def initialize(data)
    self.date = data[:date]
    self.description = data[:description]
    self.amount = data[:amount]
    self.currency = data[:currency]
    self.account_name = data[:account_name]
  end

  def to_json(*args)
    {
      date: date,
      description: description,
      amount: amount,
      currency: currency,
      account_name: account_name
    }.to_json(args)
  end
end
