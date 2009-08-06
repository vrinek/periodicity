class Period
  DAY_PERIODS = {
    "morning" => 9,
    "noon" => 12,
    "afternoon" => 19,
    "midnight" => 0
  }
  
=begin rdoc
  Initializes a new Period object with the last_run used for the next_run calculations
  
  A Period object needs at least an every and time period (minutes, hours etc) to functions properly:
    Period.new.every.day
    Period.new(2.hours.ago).every(4).hours
  
  If last_run is nil, next_run will always return Time.now
=end
  def initialize(last_run = nil)
    @last_run = last_run
    @at = 0
  end
  
=begin rdoc
  Sets the interval at which the runs should be calculated:
  
    every.day
    every(20).minutes
    every(2).hours
=end
  def every(int = 1)
    @interval = int
    return self
  end
  
=begin rdoc
  Sets the scope to one week so that <tt>every(2).weeks</tt> means "every 2 weeks"
=end
  def weeks
    @scope = 1.week
    reset_on_base 7
    
    return self
  end
  alias_method :week, :weeks
  
=begin rdoc
  Sets the scope to one day so that <tt>every(4).days</tt> means "every 4 days"
=end
  def days
    @scope = 1.days
    reset_on_base 24
    
    return self
  end
  alias_method :day, :days
  
=begin rdoc
  Sets the scope to one hour so that <tt>every(6).hours</tt> means "every 6 hours"
=end
  def hours
    @scope = 1.hour
    reset_on_base 60
    
    return self
  end
  alias_method :hour, :hours
  
=begin rdoc
  Sets the scope to one minute so that <tt>every(20).minutes</tt> means "every 20 minutes"
=end
  def minutes
    @scope = 1.minute
    reset_on_base 60
    
    return self
  end
  alias_method :minute, :minutes
  
=begin rdoc
  Sets the scope to one second so that <tt>every(5).seconds</tt> means "every 5 seconds"
=end
  def seconds
    @scope = 1.second
    reset_on_base false
    
    return self
  end
  alias_method :second, :seconds
  
=begin rdoc
  Sets the from limit based on the scope:
    every(2).hours.from(8) # means "every 2 hours beginning from 8:00"
=end
  def from(time)
    # raise "From can't be after to" if @to and @to < time
    
    @from = time
    return self
  end
  
=begin rdoc
  Sets the to limit based on the scope:
    every(2).hours.to(12) # means "every 2 hours until 12:00"
=end
  def to(time)
    # raise "To can't be before from" if @from and time < @from
    
    @to = time
    return self
  end
  
=begin rdoc
  Sets a specific "sub-time" for the next_run:
    every(2).hours.at(15) # means "every 2 hours at the first quarter of each" e.g. 12:15, 14:15, 16:15
  
  NOTE: when using at and from, to limits together the limits *always* calculate at 0 "sub-time":
    every(2).hours.at(15).from(12).to(16) # will return 12:15, 14:15 but not 16:15 because the to limit ends at 16:00
=end
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
  
=begin rdoc
  This return a Time object for the next calculated time:
    now = "Aug 05 14:40:23 2009".to_time
    Period.new(now).every(2).hours.next_run # => Wed Aug 05 16:00:00 UTC 2009
    
  Note that it rounds all "sub-time" to 0 by default (can be overriden with at)
=end
  def next_run
    return Time.now unless @last_run
    
    @next_run = @last_run
    
    if @scope and @interval
      @next_run += @interval * @scope
      
      calc_precision
      
      calc_limits
    else
      raise 'No proper period specified'
    end
    
    return @next_run
  end
  
  private
  
  def reset_on_base(base)
    @interval = 1 unless base
    
    @interval = case @interval.to_s
    when /half/i
      @scope = @scope/base
      base/2
    when /quarter/i
      @scope = @scope/base
      base/4
    when /other/i
      2
    else
      @interval
    end
  end
  
  def calc_precision(scope = nil)
    @at = 0 if scope

    if down = downtime(scope || @scope)
      unless now(down) == @at
        @next_run += (@at - now(down)) * down
      end
      calc_precision down
    end
  end
  
  def calc_limits
    if @from and @to and @from > @to # aka overnight limits
      if now < @from
        @next_run += (
        if @to < now + (now(downtime)*(downtime / @scope.to_f) || 0)
          @from - now
        else
          0
        end
        ) * @scope
      end

      if now > @to and @from < @to
        @next_run += (@from - now) * @scope + uptime
      end
    elsif @from or @to
      if @from and now < @from
        @next_run += (@from - now) * @scope
      elsif @to and now > @to
        @next_run += ((@from || 0) - now) * @scope + uptime
      end
    end
  end
  
  def now(scope = nil)
    case scope || @scope
    when 1.second
      @next_run.sec
    when 1.minute
      @next_run.min
    when 1.hour
      @next_run.hour
    when 1.day
      @next_run.day
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
  
  def downtime(scope = nil)
    case scope || @scope
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
