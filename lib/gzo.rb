require 'rest_client'
require 'utils'

include Utils

module Gzo
  def api_endpoint
    key = Rails.application.secrets.gzo_api_key
    domain = Rails.application.secrets.gzo_domain

    "https://#{key}@#{domain}/api/v2/"
  end

  def ping
    RestClient.get "#{api_endpoint}ping"
  end

  def delete_all_cashflows(user_id)
    response_body(cashflow_incomes(user_id))['incomes'].each do |income|
      id = income['id']
      RestClient.delete "#{api_endpoint}users/#{user_id}/cashflow/incomes/#{id}"
    end

    response_body(cashflow_bills(user_id))['bills'].each do |bill|
      id = bill['id']
      RestClient.delete "#{api_endpoint}users/#{user_id}/cashflow/bills/#{id}"
    end
  end

  def create_cashflow_bill(user_id, options={})
    validate_options([:amt, :freq, :name, :start_date], options.keys)

    RestClient.post("#{api_endpoint}users/#{user_id}/cashflow/bills",
                    { :bill => {
                        :amount => options[:amt],
                        :frequency => options[:freq],
                        :name => options[:name],
                        :start_date => options[:start_date]
                      }
                    }.to_json,
                    :content_type => :json,
                    :accept => :json)
  end

  def create_cashflow_income(user_id, options={})
    validate_options([:amt, :freq, :name, :start_date], options.keys)

    RestClient.post("#{api_endpoint}users/#{user_id}/cashflow/incomes",
                    { :income => {
                        :amount => options[:amt],
                        :frequency => options[:freq],
                        :name => options[:name],
                        :start_date => options[:start_date]
                      }
                    }.to_json,
                    :content_type => :json,
                    :accept => :json)
  end

  def cashflow_bills(user_id)
    RestClient.get "#{api_endpoint}users/#{user_id}/cashflow/bills"
  end

  def cashflow_incomes(user_id)
    RestClient.get "#{api_endpoint}users/#{user_id}/cashflow/incomes"
  end

  def synthesize_future_cashflow_events(cashflow)
    future_events = []
    start_date = cashflow['start_date'].to_date
    dates = frequency_to_dates(frequency_to_hash(cashflow['frequency']),
                               start_date,
                               (start_date + 6.months))
    future_events = dates.map do |date|
      { :name => cashflow['name'],
        :amount => cashflow['amount'],
        :weekdate => date.strftime("%G-W%V-%u"),
        :date => date }
    end
  end

  def future_cashflow_bills(user_id)
    bills = response_body(cashflow_bills(user_id))['bills']
    future_bills = bills.map do |bill|
      synthesize_future_cashflow_events(bill)
    end

    future_bills.flatten.sort_by { |b| b[:date] }
  end

  def future_cashflow_incomes(user_id)
    incomes = response_body(cashflow_incomes(user_id))['incomes']
    future_incomes = incomes.map do |income|
      synthesize_future_cashflow_events(income)
    end

    future_incomes.flatten.sort_by { |b| b[:date] }
  end

  def future_cashflows(user_id)
    cashflows = (future_cashflow_bills(user_id) +
                 future_cashflow_incomes(user_id))

    cashflows.sort_by { |cashflow| cashflow[:date] }
  end

  def checking_account_balance(user_id)
    uri = "#{api_endpoint}users/#{user_id}/accounts"
    accts = response_body(RestClient.get uri)['accounts']
    checking = accts.select { |a| a['display_account_type'] == 'checking' }[0]
    balance = BigDecimal.new(checking['balance'])
  end

  def weekly_future_debits(user_id)
    bills_by_week = future_cashflow_bills(user_id).group_by do |h|
      h[:weekdate][0..-3]
    end
    bills_by_week.map do |week,bills|
      { week => (bills.reduce(0) do |sum,bill|
                   sum + bill[:amount].to_d
                 end)
      }
    end
  end

  def weekly_future_credits(user_id)
    incomes_by_week = future_cashflow_incomes(user_id).group_by do |h|
      h[:weekdate][0..-3]
    end
    incomes_by_week.map do |week,incomes|
      { week => (incomes.reduce(0) do |sum,income|
                   sum + income[:amount].to_d
                 end)
      }
    end
  end

  def weekly_future_cashflow(user_id)
    start_date = future_cashflows(user_id).min_by { |flo| flo[:date] }[:date]
    end_date = future_cashflows(user_id).max_by { |flo| flo[:date] }[:date]

    dates = frequency_to_dates(frequency_to_hash('Weekly'),
                               start_date,
                               end_date)
    weeks = dates.map { |d| d.strftime("%G-W%V") }

    credits = weekly_future_credits(user_id)
    debits = weekly_future_debits(user_id)

    weeks.map do |week|
      total_credits = credits.select { |cr| cr[week] }.reduce(0) do |sum,h|
        sum + h[week]
      end
      total_debits = debits.select { |dr| dr[week] }.reduce(0) do |sum,h|
        sum + h[week]
      end

      { :week => week, :cashflow => total_credits + total_debits }
    end
  end

  def weekly_future_balances(user_id)
    sum = checking_account_balance(user_id)
    weekly_future_cashflow(user_id).map { |net| net[:cashflow] }.map do |x|
      sum += x
    end
  end

end
