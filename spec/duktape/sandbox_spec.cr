require "../spec_helper"

describe Duktape::Sandbox do
  describe "initialize" do
    context "without timeout" do
      it "should create a new sandbox instance" do
        sbx = Duktape::Sandbox.new

        sbx.should be_a(Duktape::Sandbox)
        sbx.timeout?.should be_false
      end
    end

    context "with timeout" do
      it "should raise if timeout < 100" do
        expect_raises ArgumentError, /> 100ms/ do
          Duktape::Sandbox.new 99
        end
      end

      it "should create a sandbox with a timeout" do
        sbx = Duktape::Sandbox.new 500
        sbx.timeout.should eq(500)
        sbx.timeout?.should be_true
      end
    end

    it "should remove the require keyword" do
      sbx = Duktape::Sandbox.new
      js = <<-JS
        var test = require('foo');
      JS

      expect_raises Duktape::ReferenceError, /identifier 'require' undefined/ do
        sbx.eval_string! js
      end
    end

    it "should remove the Duktape global object" do
      sbx = Duktape::Sandbox.new
      js = <<-JS
        Duktape.version;
      JS

      expect_raises Duktape::ReferenceError, /identifier 'Duktape' undefined/ do
        sbx.eval_string! js
      end
    end

    it "should have a stack top of 0" do
      sbx = Duktape::Sandbox.new

      sbx.get_top.should eq(0)
    end
  end

  describe "sandbox?" do
    it "should return true" do
      sbx = Duktape::Sandbox.new

      sbx.sandbox?.should be_true
    end
  end

  describe "should_gc?" do
    it "should return true for a newly-created heap" do
      sbx = Duktape::Sandbox.new

      sbx.should_gc?.should be_true
    end

    it "should return false when initialized as wrapper obj" do
      sbx = Duktape::Sandbox.new
      wrapper = Duktape::Sandbox.new sbx.raw

      wrapper.should_gc?.should be_false
    end
  end

  describe "timeout?" do
    it "should return false when no timeout" do
      sbx = Duktape::Sandbox.new

      sbx.timeout?.should be_false
    end

    it "should return true when a timeout is specified" do
      sbx = Duktape::Sandbox.new 200

      sbx.timeout?.should be_true
    end
  end

  describe "timeout" do
    it "should return nil when no timeout" do
      sbx = Duktape::Sandbox.new

      sbx.timeout.should be_nil
    end

    it "should return an Int64 if timeout is specified" do
      sbx = Duktape::Sandbox.new 200

      sbx.timeout.should be_a(Int64)
      sbx.timeout.should eq(200)
    end
  end

  describe "timeout=" do
    it "should alter the timeout value" do
      sbx = Duktape::Sandbox.new(200.milliseconds)
      sbx.timeout = 500.milliseconds
      sbx.timeout.should eq 500
    end
  end

  context "timeout during evaluation" do
    it "should raise a Duktape::RangeError on timeout" do
      sbx = Duktape::Sandbox.new(100)
      expect_raises Duktape::RangeError, /execution timeout/ do
        sbx.eval! <<-JS
          while (true) {}
        JS
      end
    end

    it "should respect an updated timeout when altered" do
      sbx = Duktape::Sandbox.new(100)

      t = Time.measure do
        begin
          sbx.eval! <<-JS
              while (true) {}
            JS
        rescue ex
        end
      end
      t.should be >= 100.milliseconds

      sbx.timeout = 500.milliseconds

      t = Time.measure do
        begin
          sbx.eval! <<-JS
              while (true) {}
            JS
        rescue ex
        end
      end
      t.should be >= 100.milliseconds
    end
  end
end
