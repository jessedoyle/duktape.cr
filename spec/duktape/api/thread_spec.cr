require "../../spec_helper"

describe Duktape::API::Thread do
  it "suspends and resumes execution" do
    ctx = Duktape::Context.new
    ctx.push_thread
    other = ctx.require_context -1
    initial_stack = ctx.stack
    state = ctx.suspend
    other.eval_string!("1 + 1")
    other.suspend
    ctx.resume state
    initial_stack.should eq ctx.stack
  end
end
