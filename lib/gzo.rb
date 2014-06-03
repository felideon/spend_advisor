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

  def cashflow_bills(user_id)
    RestClient.get "#{api_endpoint}users/#{user_id}/cashflow/bills"
  end

  def cashflow_incomes(user_id)
    RestClient.get "#{api_endpoint}users/#{user_id}/cashflow/incomes"
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

  def synthesize_future_cashflow_events(cashflow)
    future_events = []
    weekdates = frequency_to_weekdates(frequency_to_hash(cashflow['frequency']),
                                       Date.today,
                                       (Date.today + 6.months))
    future_events = weekdates.map do |date|
      { :name => cashflow['name'],
        :amount => cashflow['amount'],
        :weekdate => date }
    end
  end

end
