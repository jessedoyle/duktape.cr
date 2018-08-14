require "../../spec_helper"

describe Duktape::API::Math do
  describe "#random" do
    it "returns a Float64 between 0 and 1" do
      ctx = Duktape::Context.new
      val = ctx.random
      (0..1).should contain(val)
    end
  end
end
