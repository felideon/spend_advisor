# SpendAdvisor

SpendAdvisor is a simple application designed to answer one question:
Can I afford to spend $x right now? It uses the Geezeo API and thus
requires access thereto.

## Getting Started

Before running the application, you will need to set up a few things.

### Environment Variables

In order to not leak the following sensitive information, the
`secrets.yml` has been used to grab some values from the environment, like so:

```ruby
gzo_api_key: <%= ENV["GZO_API_KEY"] %>
gzo_cust_id: <%= ENV["GZO_CUST_ID"] %>
gzo_domain: <%= ENV["GZO_DOMAIN"] %>
gzo_user_id: <%= ENV["GZO_USER_ID"] %>
```

So in your `.bashrc` or similar, export these four keys using the
appropriate values provided by Geezeo, for example:

```bash
export GZO_API_KEY=pneumonoultramicroscopicsilicovolcanoconiosissupercalifragilisticexpialidocious
export GZO_CUST_ID=example
export GZO_DOMAIN=dev.example.com
export GZO_USER_ID=auntmae
```

Make sure you `source` your startup file before running tests or the rails server.

### Seed Data

The Geezeo user will have to have a checking account that is reporting
a balance, as well as Cashflow Bills and Cashflow Incomes.

For the latter, a rake script has been created to generate a few
sample cashflow bills and incomes. However, the accout balance cannot
be frobbed as far as I can tell. (At least not from the API,
for obvious reasons.) To run the script:

`$ rake data:all`

Two rake tasks will be run: one for deleting all cashflow bills and
incomes, and one that recreates them.

You may also create your own cashflow data by modifying the
`lib/tasks/test_cashflow_bills.yml` and
`lib/tasks/test_cashflow_incomes.yml` files accordingly, and running
the rake script.

### Running the tests (optional)

To run tests, simply run `rake test test/models/gzo_test.rb`. There
are no tests for the controller or UI yet. 

Also, **make sure to re-run** the `rake data:all` after running tests to
reset the generated cashflows as per the seed data (YAML files).

### Run the server

`$ rails server` should do the trick! This is what it is supposed to look like:

![SpendAdvisor screenshot](app/assets/images/spendadvisor.png?raw=true)

## Planned Features

These are features I had in mind but have not gotten around to implement.

### Answers should be more nuanced

Rather than a Yes/No answer, I thought it would be a good idea to have
four different answers, such as:

* Definitely not
* Probably not
* Yes, but barely
* Yes, all things being equal

Or something to that effect. Also, each answer would be accompanied by
an appropriate animated reaction gif. :)

### Parameterization

#### Minimum account balance

Currently, the minimum balance that needs to be maintained on the
account is set to $100. Anything below that will cause a "No"
answer. The user should have the option to set their own amount.

#### Risk multiplier

Since cashflow forecasting is trick at the personal level, there
should be more wiggle room for unforeseen circumstances. The user
should have the option to set a "risk multiplier" which would decrease
the confidence level in the answer given. This could also be used by
users with irregular income to adjust for gaps and such.

## Further thoughts

### Cash flow vs statistical analysis of transactions 

In reality, the cashflow forecasting should should consider historical
data (actual cashflow events) in order to validate the reality of a
cashflow based decision. If your cashflow for the past 6-12 months has
been completely dissonant with the planned cashflow, the decision
should reflect this or at least inform the dissonance.

Alternatively, the cashflow could simply be generated or seeded based
on historical data, and the software would continue to work as
is. However, this requires that the user has enough transactions on
which to perform statistical analysis.

### Show why the decision was made

Show the cashflow bill and week on which the account balance would go
below minimum account balance.

Also potentially show which cashflow income would cause the account
balance to go back above the min-acct-bal, and how long that would
take.

### Visualization

A nice feature would be to have a nice visualization of your cashflow
forecast, and how and immediate expense would affect
it. (Alternatively, simply create a new cashflow with a 'once'
frequency and re-run the calculations.)
