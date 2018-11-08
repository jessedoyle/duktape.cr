require "../../spec_helper"

describe Duktape::API::Thread do
  describe "suspend" do
    it "suspends Duktape execution" do
      ctx = Duktape::Context.new
      ctx.push_global_proc("test") do |ptr|
        env = Duktape::Context.new ptr
        env.suspend
        # as the engine is suspended, we should not evaluate 'true'
        env.eval("true")
        env.get_boolean(-1).should be_false
        env.call_success
      end
      ctx.eval("test();")
    end
  end

  describe "resume" do
    it "resumes Duktape execution" do
      ctx = Duktape::Context.new
      ctx.push_global_proc("test") do |ptr|
        env = Duktape::Context.new ptr
        state = env.suspend
        # do some blocking I/0 here...
        env.resume(state)
        env.eval("true")
        env.get_boolean(-1).should be_true
        env.call_success
      end
      ctx.eval("test();")
    end
  end
end
