module Spec
  class JSTypeExpectation(T)
    def initialize(@target : T); end

    def match(value : Int32)
      @target == Duktape::TYPES[value]
    end

    def failure_message(actual_value)
      "expected #{@target.inspect}, got #{Duktape::TYPES[actual_value].inspect}"
    end

    def negative_failure_message(actual_value)
      "expected: #{@target.inspect}\nto not be #{Duktape::TYPES[actual_value].inspect}"
    end
  end

  module Expectations
    def be_js_type(value)
      Spec::JSTypeExpectation.new value
    end
  end
end
