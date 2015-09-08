module Spec
  class JSTypeExpectation(T)
    def initialize(@target : T); end

    def match(@value : Int32)
      @target == Duktape::TYPES[@value]
    end

    def failure_message
      "expected #{@target.inspect}\, got #{Duktape::TYPES[@value].inspect}"
    end

    def negative_failure_message
      "expected: #{@target.inspect}\nto not be #{Duktape::TYPES[@value].inspect}"
    end
  end

  module Expectations
    def be_js_type(value)
      Spec::JSTypeExpectation.new value
    end
  end
end
