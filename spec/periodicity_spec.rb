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
    
    period.every.day.at(:midnight).next_run.should == "Aug 06 00:00:00 2009".to_time
    period.every.day.at(:midnight).next_run(1).should == "Aug 07 00:00:00 2009".to_time
    period.every.day.at(:midnight).next_run(2).should == "Aug 08 00:00:00 2009".to_time

    period.every.day.at('5').next_run.should == "Aug 06 05:00:00 2009".to_time
    period.every.day.at('5:00').next_run.should == "Aug 06 05:00:00 2009".to_time
    period.every.day.at('05:00').next_run.should == "Aug 06 05:00:00 2009".to_time
    
    lambda {period.every.day.at('05:30').next_run}.should raise_error # not yet implemented
  end
  
  it "should return correct time with precision" do
    period.every.week.at(20).next_run.should == "Aug 12 20:00:00 2009".to_time
    period.every.day.at(14).next_run.should == "Aug 06 14:00:00 2009".to_time
    
    period.every.hour.at(30).next_run.should == "Aug 05 15:30:00 2009".to_time
    period.every.hour.at(30).next_run(1).should == "Aug 05 16:30:00 2009".to_time
    period.every.hour.at(30).next_run(2).should == "Aug 05 17:30:00 2009".to_time
  end
  
  it "should take into account the limits" do
    period.every(2).hours.from(18).next_run.should == "Aug 05 18:00:00 2009".to_time
    period.every.hour.from(13).next_run.should == "Aug 05 15:00:00 2009".to_time
    period.every(2).hours.from(12).next_run.should == "Aug 05 16:00:00 2009".to_time
    
    period.every(2).hours.from(21).next_run.should == "Aug 05 21:00:00 2009".to_time
    period.every(2).hours.from(21).next_run(1).should == "Aug 05 23:00:00 2009".to_time
    period.every(2).hours.from(21).next_run(2).should == "Aug 06 21:00:00 2009".to_time
    
    period.every(2).hours.to(12).next_run.should == "Aug 06 00:00:00 2009".to_time
    period.every(2).hours.to(12).next_run(1).should == "Aug 06 02:00:00 2009".to_time
    period.every(2).hours.to(12).next_run(2).should == "Aug 06 04:00:00 2009".to_time
    
    period.every(5).minutes.from(15).to(50).next_run(0).should == "Aug 05 14:45:00 2009".to_time
    period.every(5).minutes.from(15).to(50).next_run(1).should == "Aug 05 14:50:00 2009".to_time
    period.every(5).minutes.from(15).to(50).next_run(2).should == "Aug 05 15:15:00 2009".to_time
    # period.every(5).minutes.from(15).to(50).next_run(3).should == "Aug 05 15:20:00 2009".to_time # skip has limits...

    period.every(2).hours.from(8).to(12).next_run(0).should == "Aug 06 08:00:00 2009".to_time
    period.every(2).hours.from(8).to(12).next_run(1).should == "Aug 06 10:00:00 2009".to_time
    period.every(2).hours.from(8).to(12).next_run(2).should == "Aug 06 12:00:00 2009".to_time
    period.every(2).hours.from(8).to(12).next_run(3).should == "Aug 07 08:00:00 2009".to_time
    # period.every(2).hours.from(8).to(12).next_run(4).should == "Aug 07 10:00:00 2009".to_time # skip has limits...

    period.every(3).days.from(5).to(20).next_run(0).should == "Aug 08 00:00:00 2009".to_time
    period.every(3).days.from(5).to(20).next_run(1).should == "Aug 11 00:00:00 2009".to_time
    period.every(3).days.from(5).to(20).next_run(2).should == "Aug 14 00:00:00 2009".to_time
    period.every(3).days.from(5).to(20).next_run(3).should == "Aug 17 00:00:00 2009".to_time
    period.every(3).days.from(5).to(20).next_run(4).should == "Aug 20 00:00:00 2009".to_time
    period.every(3).days.from(5).to(20).next_run(5).should == "Sep 05 00:00:00 2009".to_time
  end
  
  it "should avoid some pitfalls" do
    Period.new("Aug 05 14:41:23 2009".to_time).every.hour.at(40).next_run.should == "Aug 05 15:40:00 2009".to_time
    Period.new("Aug 05 14:39:23 2009".to_time).every.hour.at(40).next_run.should == "Aug 05 15:40:00 2009".to_time
    
    lambda {period.from(5).to(1)}.should raise_error
    lambda {period.to(1).from(5)}.should raise_error
  end
  
  def period
    return Period.new("Aug 05 14:40:23 2009".to_time)
  end
end
