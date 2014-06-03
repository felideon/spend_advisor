module Utils
  def validate_options(valid_keys, test_keys)
    invalid_keys = test_keys - valid_keys
    raise "Invalid keys: #{test_keys}" unless invalid_keys.empty?
  end

  def response_body(response)
    JSON.parse(response.body)
  end

  def frequency_to_weekdates(freq, start_date, end_date)
    dates = []
    num_intervals = nil

    case freq[:interval]
    when 'day'
      num_intervals = (end_date - start_date).to_i
    when 'week'
      num_intervals = ((end_date - start_date).to_i / 7)
    when 'month'
      num_intervals = ((end_date - start_date).to_i / 30)
    when 'year'
      num_intervals = ((end_date - start_date).to_i / 365)
    end

    dates << (0..num_intervals).step(freq[:units]).map do |i|
      start_date + i.send(freq[:interval])
    end

    # return dates in ISO 8601 week date format
    dates.flatten.map { |d| d.strftime("%G-W%V-%u") }
  end
end
