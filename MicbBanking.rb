require 'pry'
require 'watir'
require 'nokogiri'
require 'json'
require 'date'
require 'time'
require 'io/console'
require_relative 'accounts.rb'
require_relative 'transactions.rb'

# Micb_Banking class represents interaction with user's banking data
class MicbBanking
  BASE_URL = 'https://wb.micb.md/way4u-wb2/'.freeze
  ACCOUNTS_URL = 'https://wb.micb.md/way4u-wb2/#menu/WB_MAIN_MENU.NEW_CARDS_ACCOUNTS'.freeze
  TRANSACTIONS_URL = 'https://wb.micb.md/way4u-wb2/#menu/WB_MAIN_MENU.TR_HISTORY/WB_OPER_HISTORY.CP_HISTORY'.freeze

  attr_reader :accounts, :transactions

  def execute
    request_credentials
    open_browser
    authenticate
    get_accounts(accounts_page_html)
    get_transactions
    accounts_and_transactions
    export_to_json
    show_banking_data
  end

  private

  def request_credentials
    puts 'Please write your account login:'
    @login = $stdin.gets.chomp
    puts 'Please write your account password:'
    @password = STDIN.noecho(&:gets).chomp
  end

  def open_browser
    @browser = Watir::Browser.new
    @browser.goto(BASE_URL)
  end

  def authenticate
    @browser.text_field(type: 'text').set(@login)
    @browser.text_field(id: 'password').set(@password)
    @browser.send_keys:enter
    sleep 1
  end

  def accounts_page_html
    @browser.goto(ACCOUNTS_URL)
    @browser.div(class: 'contracts-section').html
  end

  def get_accounts(html)
    parsed_accounts = Nokogiri::HTML.parse(html)
    @accounts = []
    @nature = parsed_accounts.at_css('.section-title', '.h-small').text
    parsed_accounts.css('div.status-active').map do |account|
      name      = account.at_css('.name').text
      balance   = account.css('.amount').first.text
      currency  = account.at_css('.icon').text
      account   = Account.new(name: name,
                             balance: balance,
                             currency: currency,
                             nature: @nature)
      @accounts << account
    end
  end

  def set_date
    day = Date.today.prev_month(2).day.to_s
    @browser.input(name: 'from').click
    @browser.a(class: %w'ui-datepicker-prev ui-corner-all').click
    @browser.a(text: day).click
  end


  def get_transactions
    @browser.goto(TRANSACTIONS_URL)
    set_date
    sleep 1
    @accounts.each do |account|
      @browser.div(class: 'chosen-container').click
      @browser.div(class: 'chosen-drop').span(text: account.name).click
      sleep 1
      if !@browser.div(class: 'operations').div(class: 'empty-message').present?
        html = @browser.div(class: 'operations').html
        account.transactions = get_transactions_from_html(html)
      end
    end
  end

  def get_transactions_from_html(html)
    transactions = []
    Nokogiri::HTML.parse(html).css('li.history-item.success').each do |item|
      year        = item.xpath('../../preceding-sibling::div[@class = "month-delimiter"]').last.text.split[1]
      month_name  = item.xpath('../../preceding-sibling::div[@class = "month-delimiter"]').last.text.split[0]
      day         = item.parent.parent.css('div.day-header').text.split[0]
      time        = item.css('span.history-item-time').text
      date        = "#{time} #{day} #{month_name} #{year}"

      description = item.css('span.history-item-description').text
      amount      = item.css('span.history-item-amount.transaction').css('span[class="amount"]').text
      currency    = item.css('span.history-item-amount.transaction').css('span.amount.currency').text

      transactions << Transactions.new(date, description, amount, currency)
    end
    transactions
  end

  def accounts_and_transactions
    final_hash = {}
    final_hash['accounts'] = @accounts.map do |account|
      {
        'name'         => account.name,
        'balance'      => account.balance,
        'currency'     => account.currency,
        'nature'       => account.nature,
        'transactions' => account.transactions.map do |transaction|
          {
            'date'        => transaction.date,
            'description' => transaction.description,
            'amount'      => transaction.amount,
            'currency'    => transaction.currency
          }
        end
        }
    end
    final_hash
  end

  def export_to_json
    @file_name = 'accounts_and_transactions.json'
    File.open("#{@file_name}", 'w') do |file|
      file.write(JSON.pretty_generate(accounts_and_transactions))
    end
  end

  def show_banking_data
    puts "Your banking information was saved to #{@file_name} file"
    puts 'Your transactions for the last two months:'
    puts File.read("#{@file_name}")
  end


end
