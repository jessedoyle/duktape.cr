# We need to use a macro to generate code here
# to avoid Crystal thinking that we are passing
# a closure to a c binding.
# Note: This assumes `ctx` is already a valid Duktape::Context
macro proc_should_return_error(error)
  it "should push {{error.id}} error to the stack when called" do
    ctx.push_proc do |ptr|
      env = Duktape::Context.new ptr
      env.call_failure {{error}}
    end

    ctx.call 0

    ctx.is_error(-1).should be_true
    ctx.safe_to_string(-1).should match(/{{error.id}}/i)
  end
end
