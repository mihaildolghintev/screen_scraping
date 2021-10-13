require_relative 'manager'


Manager.create_session
account_links = Manager.account_links
result = []
account_links.each do |link|
  account = Manager.fetch_account_data link
  Manager.download_report! link, account
  transactions = Manager.create_transactions_from_csv(account)
  account.transactions = transactions
  result << account.to_json
end
puts result

