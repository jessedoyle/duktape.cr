require "../spec_helper"

describe Duktape::Sandbox do
  describe "initialize" do
    it "should create a new sandbox instance" do
      sbx = Duktape::Sandbox.new

      sbx.should be_a(Duktape::Sandbox)
    end

    it "should remove the require keyword" do
      sbx = Duktape::Sandbox.new
      js = <<-JS
        var test = require('foo');
      JS

      expect_raises Duktape::Error, /ReferenceError/ do
        sbx.eval_string! js
      end
    end

    it "should remove the Duktape global object" do
      sbx = Duktape::Sandbox.new
      js = <<-JS
        Duktape.version;
      JS

      expect_raises Duktape::Error, /ReferenceError/ do
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
end
