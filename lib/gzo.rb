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
    dates = frequency_to_dates(frequency_to_hash(cashflow['frequency']),
                                   Date.today,
                                   (Date.today + 6.months))
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

  def checking_account_balance(user_id)
    uri = "#{api_endpoint}users/#{user_id}/accounts"
    accts = response_body(RestClient.get uri)['accounts']
    checking = accts.select { |a| a['display_account_type'] == 'checking' }[0]
    balance = BigDecimal.new(checking['balance'])
  end

  def weekly_future_bills(user_id)
    bills_by_week = future_cashflow_bills(user_id).group_by do |h|
      h[:weekdate][0..-3]
    end
    bills_by_week.map do |week,bills|
      { week => (bills.reduce(0) do |sum,bill|
                   sum + bill[:amount].to_f
                 end)
      }
    end
  end

  def weekly_future_incomes(user_id)
    incomes_by_week = future_cashflow_incomes(user_id).group_by do |h|
      h[:weekdate][0..-3]
    end
    incomes_by_week.map do |week,incomes|
      { week => (incomes.reduce(0) do |sum,income|
                   sum + income[:amount].to_f
                 end)
      }
    end
  end
end
