require 'test_helper'
require 'gzo'

include Gzo

class GzoTest < ActiveSupport::TestCase
  def test_ping_returns_pong
    response = ping
    assert(response.code == 200, "HTTP Status: #{response.code}")
    assert(JSON.parse(response.body)["response"] == "PONG")
  end

  def test_create_cashflow_bill_succeeds
    response = create_cashflow_bill('nfreeman',
                                    { :amt => '120',
                                      :freq => 'Monthly',
                                      :name => 'FPL',
                                      :start_date => '2014-06-08' })
    assert_http_status(201, response.code)

    new_bill = JSON.parse(response.body)['bills'][0]
    assert_not(new_bill['id'].nil?)
    assert(BigDecimal.new(new_bill['amount']) == BigDecimal.new('-120'))
    assert(new_bill['frequency'] == 'Monthly')
    assert(new_bill['name'] == 'FPL')
    assert(new_bill['start_date'] == '2014-06-08')
  end

  def test_create_cashflow_income_succeeds
    response = create_cashflow_income('nfreeman',
                                      { :amt => '2100',
                                        :freq => 'Every other week',
                                        :name => 'Salary',
                                        :start_date => '2014-06-10' })
    assert_http_status(201, response.code)

    new_income = JSON.parse(response.body)['incomes'][0]
    assert_not(new_income['id'].nil?)
    assert(new_income['amount'] == '2100.0')
    assert(new_income['frequency'] == 'Every other week')
    assert(new_income['name'] == 'Salary')
    assert(new_income['start_date'] == '2014-06-10')
  end

  def test_cashflow_bills_present
    response = cashflow_bills('nfreeman')
    assert_http_status(200, response.code)

    assert_not(JSON.parse(response.body)['bills'].nil?)
  end

  def test_cashflow_incomes_present
    response = cashflow_incomes('nfreeman')
    assert_http_status(200, response.code)

    assert_not(JSON.parse(response.body)['incomes'].nil?)
  end
end
