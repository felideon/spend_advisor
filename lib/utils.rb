module Utils
  def validate_options(valid_keys, test_keys)
    invalid_keys = test_keys - valid_keys
    raise "Invalid keys: #{test_keys}" unless invalid_keys.empty?
  end

  def response_body(response)
    JSON.parse(response.body)
  end

  def frequency_to_hash(freq)
    case freq
    when 'Daily'
      { :units => 1, :interval => 'day' }
    when 'Every four weeks'
      { :units => 4, :interval => 'week' }
    when 'Every other week'
      { :units => 2, :interval => 'week' }
    when 'Every six months'
      { :units => 6, :interval => 'month' }
    when 'Monthly'
      { :units => 1, :interval => 'month' }
    when 'Once'
      { :units => 0, :interval => 'day' }
    when 'Quarterly'
      { :units => 2, :interval => 'month' }
    when 'Twice a month'
      { :units => 0.5, :interval => 'month' }
    when 'Weekly'
      { :units => 1, :interval => 'week' }
    when 'Yearly'
      { :units => 1, :interval => 'year' }
    end
  end

  def frequency_to_dates(freq, start_date, end_date)
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

    dates.flatten
  end

end
