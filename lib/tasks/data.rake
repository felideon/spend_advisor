require 'gzo'
include Gzo

file_dir = File.dirname(__FILE__)

namespace :data do
  namespace :cashflows do
    desc "Delete existing test cashflows"
    task delete: :environment do
    end

    desc "Create test cashflows"
    task create: :environment do
      test_income_data = YAML.load_file("#{file_dir}/test_cashflow_incomes.yml")
      test_bill_data = YAML.load_file("#{file_dir}/test_cashflow_bills.yml")

      pre_incomes = response_body(cashflow_incomes('nfreeman'))['incomes'].size
      test_income_data.values.each do |income|
        create_cashflow_income('nfreeman',
                               income.symbolize_keys)
      end

      post_incomes = response_body(cashflow_incomes('nfreeman'))['incomes'].size
      puts "# of incomes before: #{pre_incomes}"
      puts "# of incomes after: #{post_incomes}"

      pre_bills = response_body(cashflow_bills('nfreeman'))['bills'].size
      test_bill_data.values.each do |bill|
        create_cashflow_bill('nfreeman',
                               bill.symbolize_keys)
      end

      post_bills = response_body(cashflow_bills('nfreeman'))['bills'].size
      puts "# of bills before: #{pre_bills}"
      puts "# of bills after: #{post_bills}"
    end

    task :all => ["delete", "create"]
  end

  task :all => ["cashflows:all"]
end
