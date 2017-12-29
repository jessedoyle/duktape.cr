require "../../spec_helper"

describe Duktape::API::Opt do
  describe "opt_boolean" do
    context "with an invalid index" do
      it "returns the default value" do
        ctx = Duktape::Context.new

        ctx.opt_boolean(-1, true).should be_true
      end
    end

    context "when stack at index is not a boolean" do
      it "raises Duktape::TypeError" do
        ctx = Duktape::Context.new
        ctx << "string"

        expect_raises(Duktape::TypeError, /is not boolean/) do
          ctx.opt_boolean(-1, false)
        end
      end
    end

    context "when stack at index is a boolean" do
      it "returns true" do
        ctx = Duktape::Context.new
        ctx << true

        ctx.opt_boolean(-1, false).should be_true
      end
    end
  end

  describe "opt_number" do
    context "with an invalid index" do
      it "returns the default value" do
        ctx = Duktape::Context.new

        ctx.opt_number(-1, 1.2).should eq(1.2)
      end
    end

    context "when stack at index is not a number" do
      it "raises Duktape::TypeError" do
        ctx = Duktape::Context.new
        ctx << "string"

        expect_raises(Duktape::TypeError, /is not number/) do
          ctx.opt_number(-1, 1.2)
        end
      end
    end

    context "when stack at index is a number" do
      it "returns the value" do
        ctx = Duktape::Context.new
        ctx << 1.2

        ctx.opt_number(-1, 1.3).should eq(1.2)
      end
    end
  end

  describe "opt_int" do
    context "with an invalid index" do
      it "returns the default value" do
        ctx = Duktape::Context.new

        ctx.opt_int(-1, 2).should eq(2.0)
      end
    end

    context "when stack at index is not a number" do
      it "raises Duktape::TypeError" do
        ctx = Duktape::Context.new
        ctx << "string"

        expect_raises(Duktape::TypeError, /is not number/) do
          ctx.opt_int(-1, 2)
        end
      end
    end

    context "when stack at index is a number" do
      it "returns the value" do
        ctx = Duktape::Context.new
        ctx << 1

        ctx.opt_int(-1, 2).should eq(1.0)
      end
    end
  end

  describe "opt_uint" do
    context "with an invalid index" do
      it "returns the default value" do
        ctx = Duktape::Context.new

        ctx.opt_uint(-1, 3_u32).should eq(3.0)
      end
    end

    context "when stack at index is not a number" do
      it "raises Duktape::TypeError" do
        ctx = Duktape::Context.new
        ctx << "string"

        expect_raises(Duktape::TypeError, /is not number/) do
          ctx.opt_uint(-1, 3_u32)
        end
      end
    end

    context "when stack at index is a number" do
      it "returns the value" do
        ctx = Duktape::Context.new
        ctx << 1

        ctx.opt_uint(-1, 2_u32).should eq(1.0)
      end
    end
  end

  describe "opt_string" do
    context "with an invalid index" do
      it "returns the default value" do
        ctx = Duktape::Context.new

        ctx.opt_string(-1, "string").should eq("string")
      end
    end

    context "when stack at index is not a string" do
      it "raises Duktape::TypeError" do
        ctx = Duktape::Context.new
        ctx << false

        expect_raises(Duktape::TypeError, /is not string/) do
          ctx.opt_string(-1, "test")
        end
      end
    end

    context "when stack at index is a string" do
      it "returns the value" do
        ctx = Duktape::Context.new
        ctx << "string"

        ctx.opt_string(-1, "test").should eq("string")
      end
    end
  end

  describe "opt_lstring" do
    context "with an invalid index" do
      it "returns the default value" do
        ctx = Duktape::Context.new

        ctx.opt_lstring(-1, "string").should eq({"string", 6})
      end
    end

    context "when stack at index is not a string" do
      it "raises Duktape::TypeError" do
        ctx = Duktape::Context.new
        ctx << false

        expect_raises(Duktape::TypeError, /is not string/) do
          ctx.opt_lstring(-1, "test")
        end
      end
    end

    context "when stack at index is a string" do
      it "returns the value" do
        ctx = Duktape::Context.new
        ctx << "string"

        ctx.opt_lstring(-1, "test").should eq({"string", 6})
      end
    end
  end

  describe "opt_context" do
    context "with an invalid index" do
      it "returns the default value" do
        ctx = Duktape::Context.new
        raw = Duktape.create_heap_default

        ctx.opt_context(-1, raw).should eq(raw)
        Duktape.destroy_heap(raw)
      end
    end

    context "when stack at index is not a thread" do
      it "raises Duktape::TypeError" do
        ctx = Duktape::Context.new
        ctx << false
        raw = Duktape.create_heap_default

        expect_raises(Duktape::TypeError, /is not thread/) do
          Duktape.destroy_heap(raw) # we won't use this pointer yet
          ctx.opt_context(-1, raw)
        end
      end
    end

    context "when stack at index is a thread" do
      it "returns the value" do
        ctx = Duktape::Context.new
        ctx.push_thread
        raw = Duktape.create_heap_default
        val = ctx.opt_context(-1, raw)

        val.should be_a(LibDUK::Context)
        val.should_not eq(raw)
        Duktape.destroy_heap(raw)
      end
    end
  end
end
