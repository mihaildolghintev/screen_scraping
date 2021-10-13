require 'watir'
require 'webdrivers'
require 'csv'
require_relative 'parser'
require_relative 'models/account'
require_relative 'models/transaction'

class Manager
  class << self
    attr_reader :browser

    BANK_URL = 'https://demo.bendigobank.com.au/banking/sign_in'.freeze
    BASE_URL = 'https://demo.bendigobank.com.au'.freeze
    DOWNLOADS_DIR = '/home/mishakos/Downloads'.freeze
    FILE_NAME = 'transactions.csv'.freeze

    def create_session
      prefs = {
        download: {
          prompt_for_download: false,
          default_directory: '.'
        }
      }
      @browser = Watir::Browser.new :chrome, options: { prefs: prefs }
      @browser.window.resize_to(1920, 1024)
    end

    def download_report!(account_link, account)

      if File.exist?("#{DOWNLOADS_DIR}/#{FILE_NAME}_#{account.name}.csv")
        File.delete("#{DOWNLOADS_DIR}/#{FILE_NAME}_#{account.name}.csv")
      end

      @browser.goto "#{BASE_URL}#{account_link}/transaction_downloads"
      @browser.li(aria_label: 'Last Quarter').click
      @browser.li(aria_label: 'Simple CSV Format').click
      @browser.button(value: 'Download').click


      report_exist = false
      current_time = Time.now.sec


      loop do
        if File.exist?("#{DOWNLOADS_DIR}/transactions.csv.crdownload")
          report_exist = true
          break
        end
        time = Time.now.sec
        break if time - current_time >= 4
      end

      loop do
        break unless File.exist?("#{DOWNLOADS_DIR}/transactions.csv.crdownload")
      end

      return unless report_exist

      File.rename("#{DOWNLOADS_DIR}/#{FILE_NAME}",
                  "#{DOWNLOADS_DIR}/#{FILE_NAME}_#{account.name}.csv")
    end

    def fetch_account_data(account_link)
      @browser.goto "#{BASE_URL}#{account_link}"
      account_page = Nokogiri::HTML5 @browser.html

      data = Parser::Account.get_account_data(account_page)
      Account.new(data)
    end

    def create_transactions_from_csv(account)
      return unless File.exist?("#{DOWNLOADS_DIR}/#{FILE_NAME}_#{account.name}.csv")

      transactions = []
      CSV.foreach("#{DOWNLOADS_DIR}/#{FILE_NAME}_#{account.name}.csv") do |row|
        res = Parser::Transaction.from_csv_line row, { name: account.name, currency: account.currency }
        tr = Transaction.new(res)
        transactions << tr
      end
      transactions
    end

    def account_links
      Parser::Account.get_account_links(index_page)
    end

    private

    def index_page
      @browser.goto BANK_URL
      @browser.button(text: 'Launch Personal Demo').click
      Nokogiri::HTML5 @browser.html
    end
  end


end
