require 'nokogiri'

module Parser
  class Account
    class << self
      def get_account_links(page)
        page.css('ol.grouped-list__group__items')
            .css('li')
            .css('a')
            .select { |a| a['href'].start_with?('/banking/accounts') }
            .map { |a| a['href'] }
            .uniq
      end

      def get_account_data(account_page_body)
        {
          name: get_account_name(account_page_body),
          balance: get_account_balance(account_page_body)
        }
      end

      private

      def parse_balance(balance_string)
        if balance_string.start_with?('Minus')
          "-#{balance_string[9..-1]}".tr(',', '').to_f
        else
          balance_string[1..-1].tr(',', '').to_f
        end
      end

      def get_account_name(account_page_body)
        account_page_body.css('h2').map(&:text).first
      end

      def get_account_balance(account_page_body)
        account_page_body.css('span')
                         .select { |s| s['data-semantic'] == 'header-current-balance-amount' }
                         .map { |b| parse_balance b.text }
                         .first
      end
    end
  end

  class Transaction
    class << self
      def from_csv_line(line, account)
        {
          date: Date.parse(line[0]).iso8601,
          description: line[2],
          amount: line[1].to_f,
          currency: account[:currency],
          acccount_name: account[:name]
        }
      end
    end
  end
end
