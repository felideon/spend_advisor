require 'gzo'
include Gzo

class MainController < ApplicationController
  def index
  end

  def spending_advice
    user_id = Rails.application.secrets.gzo_user_id
    offset = params[:amount]
    min_balance = 100 # TODO: parameterize

    amounts = weekly_future_balance_amounts(user_id, offset)
    @first_negative_position = amounts.index { |x| x < min_balance }

    render :index
  end
end
