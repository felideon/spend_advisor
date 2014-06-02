module Utils
  def validate_options(valid_keys, test_keys)
    invalid_keys = test_keys - valid_keys
    raise "Invalid keys: #{test_keys}" unless invalid_keys.empty?
  end

  def response_body(response)
    JSON.parse(response.body)
  end

end
