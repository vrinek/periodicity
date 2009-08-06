class Period
  require 'active_support'
  
  DAY_PERIODS = {
    "morning" => 9,
    "noon" => 12,
    "afternoon" => 19,
    "midnight" => 0
  }
  
  def initialize(last_run = nil)
    @last_run = last_run
    @at = 0
  end
  
  def every(int = 1)
    @interval = int
    return self
  end
  
  def weeks
    @scope = 1.week
    reset_on_base 7
    
    return self
  end
  alias_method :week, :weeks
  
  def days
    @scope = 1.days
    reset_on_base 24
    
    return self
  end
  alias_method :day, :days
  
  def hours
    @scope = 1.hour
    reset_on_base 60
    
    return self
  end
  alias_method :hour, :hours
  
  def minutes
    @scope = 1.minute
    reset_on_base 60
    
    return self
  end
  alias_method :minute, :minutes
  
  def from(time)
    raise "From can't be after to" if @to and @to < time
    
    @from = time
    return self
  end
  
  def to(time)
    raise "To can't be before from" if @from and time < @from
    
    @to = time
    return self
  end
  
  def at(time)
    unless time.is_a?(Integer)
      time = case time.to_s
      when /^\d+:00$/
        time[/^\d+/].to_i
      when /^\d+:\d{2}$/
        raise 'Precise timing like "20:15" is not yet supported'
      when /^(noon|afternoon|midnight|morning)$/
        DAY_PERIODS[time.to_s]
      else
        time.to_i
      end
    end
    
    @at = time
    return self
  end
  
  def next_run(skip = 0)
    return Time.now unless @last_run
    
    @next_run = @last_run
    
    if @scope and @interval
      @next_run += @interval * @scope
      
      calc_precision
      
      calc_limits
      
      unless skip.zero?
        @next_run += @interval * @scope * skip

        calc_limits
      end
    else
      raise 'No proper period specified'
    end
    
    return @next_run
  end
  
  private
  
  def reset_on_base(base)
    @interval = case @interval.to_s
    when /half/i
      @scope = @scope/base
      base/2
    when /quarter/i
      @scope = @scope/base
      base/4
    else
      @interval
    end
  end
  
  def calc_precision(scope = nil)
    @at = 0 if scope
    
    case scope || @scope
    when 1.minute
      unless @next_run.sec == @at
        @next_run += (@at - @next_run.sec)
      end
    when 1.hour
      unless @next_run.min == @at
        @next_run += (@at - @next_run.min).minutes
      end
      calc_precision 1.minute
    when 1.day
      unless @next_run.hour == @at
        @next_run += (@at - @next_run.hour).hours
      end
      calc_precision 1.hour
    when 1.week
      unless @next_run.hour == @at
        @next_run += (@at - @next_run.hour).hours
      end
      calc_precision 1.hour
    end
  end
  
  def calc_limits
    if @from or @to
      now = case @scope
      when 1.second
        @next_run.sec
      when 1.minute
        @next_run.min
      when 1.hour
        @next_run.hour
      when 1.day
        @next_run.day
      end
      
      if @from and now < @from
        @next_run += (@from - now) * @scope
      elsif @to and now > @to
        @next_run += ((@from || 0) - now) * @scope + uptime
      end
    end
  end
  
  def uptime
    case @scope
    when 1.second
      1.minute
    when 1.minute
      1.hour
    when 1.hour
      1.day
    when 1.day
      days_of_month.days
    when 1.week
      days_of_month.days
    end
  end
  
  def downtime
    case @scope
    when 1.minute
      1.second
    when 1.hour
      1.minute
    when 1.day
      1.hour
    when 1.week
      1.hour
    end
  end
  
  def days_of_month
    (Date.new(Time.now.year, 12, 31).to_date << (12 - @last_run.month)).day
  end
end
