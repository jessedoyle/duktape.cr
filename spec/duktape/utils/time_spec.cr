require "../../spec_helper"

describe Duktape::Support::Time do
  time = TimeMock.new

  describe "current_time_nano" do
    it "should return a Timeval containing current time" do
      tv = time.current_time_nano

      tv.should be_a(LibC::Timeval)
      tv.tv_sec.should be_a(LibC::TimeT)
      tv.tv_usec.should be_a(LibC::SusecondsT)
    end
  end

  describe "milli_to_sec_time_t" do
    it "should convert milliseconds to seconds as TimeT (truncating millisecs)" do
      milli = 5550
      secs = time.milli_to_sec_time_t milli

      secs.should be_a(LibC::TimeT)
      secs.should eq(5)
    end
  end

  describe "milli_to_micro_usec_t" do
    it "should convert milliseconds to microseconds as SusecondsT (subtracting seconds)" do
      milli = 17123
      usecs = time.milli_to_micro_usec_t milli

      usecs.should be_a(LibC::SusecondsT)
      usecs.should eq(123000)
    end
  end

  describe "timeout_timeval" do
    it "should create a Timeval for timeout specified" do
      timeout = 3732_i64
      tv = time.timeout_timeval timeout

      tv.should be_a(LibC::Timeval)
      tv.tv_sec.should eq(3)
      tv.tv_usec.should eq(732000)
    end
  end
end
