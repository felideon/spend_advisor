require 'rest_client'

module Gzo
  def api_endpoint
    key = Rails.application.secrets.gzo_api_key
    domain = Rails.application.secrets.gzo_domain
    
    "https://#{key}@#{domain}/api/v2/"
  end

  def ping
    RestClient.get "#{api_endpoint}ping"
  end

end
