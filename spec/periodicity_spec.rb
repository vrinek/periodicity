require File.dirname(__FILE__) + '/spec_helper.rb'

describe Period do
  it "should return now if not run before" do
    Period.new.next_run.to_i.should == Time.now.to_i
  end
  
  it "should raise when period not set properly" do
    lambda {Period.new(Time.now).next_run}.should raise_error
    lambda {Period.new(Time.now).every(12).next_run}.should raise_error
    lambda {Period.new(Time.now).minutes.next_run}.should raise_error
  end
  
  it "should return correct time on simple stuff" do
    period.every(3).weeks.next_run.should == "Aug 26 00:00:00 2009".to_time
    period.every(4).days.next_run.should == "Aug 09 00:00:00 2009".to_time
    period.every(2).hours.next_run.should == "Aug 05 16:00:00 2009".to_time
    period.every(30).minutes.next_run.should == "Aug 05 15:10:00 2009".to_time
  end
  
  it "should return correct time on a little bit more complex stuff" do
    period.every.day.next_run.should == "Aug 06 00:00:00 2009".to_time
    period.every(:quarter).hour.next_run.should == "Aug 05 14:55:00 2009".to_time
    period.every(:half).minute.next_run.should == "Aug 05 14:40:53 2009".to_time
    period.every(:other).hour.next_run.should == period.every(2).hours.next_run

    period.every.day.at(:morning).next_run.should == "Aug 06 09:00:00 2009".to_time
    period.every.day.at(:noon).next_run.should == "Aug 06 12:00:00 2009".to_time
    period.every.day.at(:afternoon).next_run.should == "Aug 06 19:00:00 2009".to_time
    
    (n = period.every.day.at(:midnight).next_run).should == "Aug 06 00:00:00 2009".to_time
    (n = Period.new(n).every.day.at(:midnight).next_run).should == "Aug 07 00:00:00 2009".to_time
    (n = Period.new(n).every.day.at(:midnight).next_run).should == "Aug 08 00:00:00 2009".to_time

    period.every.day.at('5').next_run.should == "Aug 06 05:00:00 2009".to_time
    period.every.day.at('5:00').next_run.should == "Aug 06 05:00:00 2009".to_time
    period.every.day.at('05:00').next_run.should == "Aug 06 05:00:00 2009".to_time
    
    lambda {period.every.day.at('05:30').next_run}.should raise_error # not yet implemented
  end
  
  it "should return correct time with precision" do
    period.every.week.at(20).next_run.should == "Aug 12 20:00:00 2009".to_time
    period.every.day.at(14).next_run.should == "Aug 06 14:00:00 2009".to_time
    
    (n = period.every.hour.at(30).next_run).should == "Aug 05 15:30:00 2009".to_time
    (n = Period.new(n).every.hour.at(30).next_run).should == "Aug 05 16:30:00 2009".to_time
    (n = Period.new(n).every.hour.at(30).next_run).should == "Aug 05 17:30:00 2009".to_time
  end
  
  it "should take into account the limits" do
    period.every(2).hours.from(18).next_run.should == "Aug 05 18:00:00 2009".to_time
    period.every.hour.from(13).next_run.should == "Aug 05 15:00:00 2009".to_time
    period.every(2).hours.from(12).next_run.should == "Aug 05 16:00:00 2009".to_time
    
    (n = period.every(2).hours.from(21).next_run).should == "Aug 05 21:00:00 2009".to_time
    (n = Period.new(n).every(2).hours.from(21).next_run).should == "Aug 05 23:00:00 2009".to_time
    (n = Period.new(n).every(2).hours.from(21).next_run).should == "Aug 06 21:00:00 2009".to_time
    
    (n = period.every(2).hours.to(12).next_run).should == "Aug 06 00:00:00 2009".to_time
    (n = Period.new(n).every(2).hours.to(12).next_run).should == "Aug 06 02:00:00 2009".to_time
    (n = Period.new(n).every(2).hours.to(12).next_run).should == "Aug 06 04:00:00 2009".to_time
    
    (n = period.every(5).minutes.from(15).to(50).next_run).should == "Aug 05 14:45:00 2009".to_time
    (n = Period.new(n).every(5).minutes.from(15).to(50).next_run).should == "Aug 05 14:50:00 2009".to_time
    (n = Period.new(n).every(5).minutes.from(15).to(50).next_run).should == "Aug 05 15:15:00 2009".to_time
    (n = Period.new(n).every(5).minutes.from(15).to(50).next_run).should == "Aug 05 15:20:00 2009".to_time

    (n = period.every(2).hours.from(8).to(12).next_run).should == "Aug 06 08:00:00 2009".to_time
    (n = Period.new(n).every(2).hours.from(8).to(12).next_run).should == "Aug 06 10:00:00 2009".to_time
    (n = Period.new(n).every(2).hours.from(8).to(12).next_run).should == "Aug 06 12:00:00 2009".to_time
    (n = Period.new(n).every(2).hours.from(8).to(12).next_run).should == "Aug 07 08:00:00 2009".to_time
    (n = Period.new(n).every(2).hours.from(8).to(12).next_run).should == "Aug 07 10:00:00 2009".to_time

    (n = period.every(3).days.from(5).to(20).next_run).should == "Aug 08 00:00:00 2009".to_time
    (n = Period.new(n).every(3).days.from(5).to(20).next_run).should == "Aug 11 00:00:00 2009".to_time
    (n = Period.new(n).every(3).days.from(5).to(20).next_run).should == "Aug 14 00:00:00 2009".to_time
    (n = Period.new(n).every(3).days.from(5).to(20).next_run).should == "Aug 17 00:00:00 2009".to_time
    (n = Period.new(n).every(3).days.from(5).to(20).next_run).should == "Aug 20 00:00:00 2009".to_time
    (n = Period.new(n).every(3).days.from(5).to(20).next_run).should == "Sep 05 00:00:00 2009".to_time
  end
  
  it "should calculate overnight limits correctly" do
    (n = period.every.hour.from(21).to(2).next_run).should == "Aug 05 21:00:00 2009".to_time
    (n = Period.new(n).every.hour.from(21).to(2).next_run).should == "Aug 05 22:00:00 2009".to_time
    (n = Period.new(n).every.hour.from(21).to(2).next_run).should == "Aug 05 23:00:00 2009".to_time
    (n = Period.new(n).every.hour.from(21).to(2).next_run).should == "Aug 06 00:00:00 2009".to_time
    (n = Period.new(n).every.hour.from(21).to(2).next_run).should == "Aug 06 01:00:00 2009".to_time
    (n = Period.new(n).every.hour.from(21).to(2).next_run).should == "Aug 06 02:00:00 2009".to_time
    (n = Period.new(n).every.hour.from(21).to(2).next_run).should == "Aug 06 21:00:00 2009".to_time
    (n = Period.new(n).every.hour.from(21).to(2).next_run).should == "Aug 06 22:00:00 2009".to_time
    (n = Period.new(n).every.hour.from(21).to(2).next_run).should == "Aug 06 23:00:00 2009".to_time
    (n = Period.new(n).every.hour.from(21).to(2).next_run).should == "Aug 07 00:00:00 2009".to_time
    (n = Period.new(n).every.hour.from(21).to(2).next_run).should == "Aug 07 01:00:00 2009".to_time
    (n = Period.new(n).every.hour.from(21).to(2).next_run).should == "Aug 07 02:00:00 2009".to_time
    (n = Period.new(n).every.hour.from(21).to(2).next_run).should == "Aug 07 21:00:00 2009".to_time

    (n = period.every.day.from(29).to(2).next_run).should == "Aug 29 00:00:00 2009".to_time
    (n = Period.new(n).every.day.from(29).to(2).next_run).should == "Aug 30 00:00:00 2009".to_time
    (n = Period.new(n).every.day.from(29).to(2).next_run).should == "Aug 31 00:00:00 2009".to_time
    (n = Period.new(n).every.day.from(29).to(2).next_run).should == "Sep 01 00:00:00 2009".to_time

    (n = period.every(3).days.from(29).to(10).next_run).should == "Aug 08 00:00:00 2009".to_time
    (n = Period.new(n).every(3).days.from(29).to(10).next_run).should == "Aug 29 00:00:00 2009".to_time
    (n = Period.new(n).every(3).days.from(29).to(10).next_run).should == "Sep 01 00:00:00 2009".to_time
    (n = Period.new(n).every(3).days.from(29).to(10).next_run).should == "Sep 04 00:00:00 2009".to_time
    (n = Period.new(n).every(3).days.from(29).to(10).next_run).should == "Sep 07 00:00:00 2009".to_time
    (n = Period.new(n).every(3).days.from(29).to(10).next_run).should == "Sep 10 00:00:00 2009".to_time
    (n = Period.new(n).every(3).days.from(29).to(10).next_run).should == "Sep 29 00:00:00 2009".to_time
    (n = Period.new(n).every(3).days.from(29).to(10).next_run).should == "Oct 02 00:00:00 2009".to_time
  end
  
  it "should calculate overnight with precision limits correctly" do
    (n = period.every.hour.at(15).from(21).to(2).next_run).should == "Aug 05 21:15:00 2009".to_time
    (n = Period.new(n).every.hour.at(15).from(21).to(2).next_run).should == "Aug 05 22:15:00 2009".to_time
    (n = Period.new(n).every.hour.at(15).from(21).to(2).next_run).should == "Aug 05 23:15:00 2009".to_time
    (n = Period.new(n).every.hour.at(15).from(21).to(2).next_run).should == "Aug 06 00:15:00 2009".to_time
    (n = Period.new(n).every.hour.at(15).from(21).to(2).next_run).should == "Aug 06 01:15:00 2009".to_time
    (n = Period.new(n).every.hour.at(15).from(21).to(2).next_run).should == "Aug 06 21:15:00 2009".to_time
    (n = Period.new(n).every.hour.at(15).from(21).to(2).next_run).should == "Aug 06 22:15:00 2009".to_time
    (n = Period.new(n).every.hour.at(15).from(21).to(2).next_run).should == "Aug 06 23:15:00 2009".to_time
    (n = Period.new(n).every.hour.at(15).from(21).to(2).next_run).should == "Aug 07 00:15:00 2009".to_time

    (n = period.every(5).minutes.at(30).from(40).to(10).next_run).should == "Aug 05 14:45:30 2009".to_time
    (n = Period.new(n).every.every(5).minutes.at(30).from(40).to(10).next_run).should == "Aug 05 14:50:30 2009".to_time
    (n = Period.new(n).every.every(5).minutes.at(30).from(40).to(10).next_run).should == "Aug 05 14:55:30 2009".to_time
    (n = Period.new(n).every.every(5).minutes.at(30).from(40).to(10).next_run).should == "Aug 05 15:00:30 2009".to_time
    (n = Period.new(n).every.every(5).minutes.at(30).from(40).to(10).next_run).should == "Aug 05 15:05:30 2009".to_time
    (n = Period.new(n).every.every(5).minutes.at(30).from(40).to(10).next_run).should == "Aug 05 15:40:30 2009".to_time
    (n = Period.new(n).every.every(5).minutes.at(30).from(40).to(10).next_run).should == "Aug 05 15:45:30 2009".to_time
    (n = Period.new(n).every.every(5).minutes.at(30).from(40).to(10).next_run).should == "Aug 05 15:50:30 2009".to_time
  end
  
  it "should avoid some pitfalls" do
    Period.new("Aug 05 14:41:23 2009".to_time).every.hour.at(40).next_run.should == "Aug 05 15:40:00 2009".to_time
    Period.new("Aug 05 14:39:23 2009".to_time).every.hour.at(40).next_run.should == "Aug 05 15:40:00 2009".to_time
    
    # lambda {period.from(5).to(1)}.should raise_error
    # lambda {period.to(1).from(5)}.should raise_error
  end
  
  def period
    return Period.new("Aug 05 14:40:23 2009".to_time)
  end
end
