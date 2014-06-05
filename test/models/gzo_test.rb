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
    assert(JSON.parse(response.body)['bills'].size == 10)
  end

  def test_cashflow_incomes_present
    response = cashflow_incomes('nfreeman')
    assert_http_status(200, response.code)

    assert_not(JSON.parse(response.body)['incomes'].nil?)
    assert(JSON.parse(response.body)['incomes'].size == 1)
  end

  def test_future_cashflow_structures
    future_cashflow_bills('nfreeman').each do |b|
      assert(b.has_key?(:name) &&
             b.has_key?(:amount) &&
             b.has_key?(:weekdate) &&
             b.has_key?(:date))
    end

    future_cashflow_incomes('nfreeman').each do |b|
      assert(b.has_key?(:name) &&
             b.has_key?(:amount) &&
             b.has_key?(:weekdate) &&
             b.has_key?(:date))
    end
  end

  def test_checking_account_balance
    assert_equal(checking_account_balance('nfreeman').to_d,
                 '300.54'.to_d)
  end

  def test_weekly_future_debits_and_credits
    weekly_future_debits('nfreeman').each do |week|
      assert_match(/201\d-W\d\d/, week.keys[0])
    end

    weekly_future_credits('nfreeman').each do |week|
      assert_match(/201\d-W\d\d/, week.keys[0])
    end
  end

  def test_weekly_future_balances
    weekly_future_balances('nfreeman').select do |w|
      assert_match(/201\d-W\d\d/, w[:week])
    end
  end

end
