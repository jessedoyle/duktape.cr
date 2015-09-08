require "../../spec_helper"

describe Duktape::API::Debug do
  describe "stack" do
    it "should return a string representation of the stack" do
      ctx = Duktape::Context.new
      str = ctx.stack

      str.should eq("ctx: top=0, stack=[]")
    end
  end

  describe "dump!" do
    it "should dump the stack string" do
      ctx = Duktape::Context.new
      ctx.dump!
    end
  end
end
