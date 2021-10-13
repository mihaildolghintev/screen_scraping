require 'json'

class Account
  attr_accessor :name, :currency, :balance, :nature, :transactions

  def initialize(data)
    self.name = data[:name]
    self.currency = data[:currency] || 'USD'
    self.balance = data[:balance]
    self.nature = data[:nature] || 'checking'
    self.transactions = data[:transactions] || []
  end

  def to_json(*args)
    {
      name: name,
      balance: balance,
      currency: currency,
      nature: nature,
      transactions: transactions
    }.to_json(args)
  end
end
