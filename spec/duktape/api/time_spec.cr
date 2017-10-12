require "../../spec_helper"

describe Duktape::API::Time do
  describe "get_now" do
    it "returns the current time (POSIX milliseconds) as a Float64" do
      ctx = Duktape::Context.new

      ctx.get_now.should be_a(Float64)
    end
  end

  describe "time_to_components" do
    it "returns LibDUK::TimeComponents" do
      ctx = Duktape::Context.new
      now = ctx.get_now
      components = ctx.time_to_components(now)

      components.should be_a(LibDUK::TimeComponents)
    end
  end

  describe "components_to_time" do
    it "converts components to a time (Float64)" do
      components = LibDUK::TimeComponents.new
      components.year = 2016
      ctx = Duktape::Context.new
      time = ctx.components_to_time(components)

      time.should eq(1451520000000.0)
    end
  end
end
