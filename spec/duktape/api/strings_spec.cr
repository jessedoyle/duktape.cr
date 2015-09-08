require "../../spec_helper"

describe Duktape::API::Strings do
  describe "char_code_at" do
    it "should return the codepoint of a char in a string" do
      ctx = Duktape::Context.new
      ctx << "C"
      code = ctx.char_code_at(-1, 0)

      code.should eq(67)
    end

    it "should raise if offset is out of bounds" do
      ctx = Duktape::Context.new
      ctx << ""

      expect_raises Duktape::Error, /out of bounds/ do
        ctx.char_code_at(-1, -1)
      end
    end

    it "should raise if index is not string" do
      ctx = Duktape::Context.new
      ctx << 123

      expect_raises Duktape::TypeError, /not string/ do
        ctx.char_code_at(-1, 0)
      end
    end
  end

  describe "concat" do
    it "should concatenate 2 strings" do
      ctx = Duktape::Context.new
      ctx << "one"
      ctx << "two"
      ctx.concat(2)
      str = ctx.require_string(-1)

      str.should eq("onetwo")
    end

    it "should concatenate 0 strings" do
      ctx = Duktape::Context.new
      ctx << "one"
      ctx << "two"
      ctx.concat(0)
      str = ctx.require_string(-1)

      str.should eq("")
    end

    it "should raise if count is invalid" do
      ctx = Duktape::Context.new
      ctx << "only one"

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.concat(2)
      end
    end
  end

  describe "join" do
    it "should join 2 strings with a separator" do
      ctx = Duktape::Context.new
      ctx << " ; " # Separator
      ctx << "one"
      ctx << "two"
      ctx.join(2)
      str = ctx.require_string(-1)

      str.should eq("one ; two")
    end

    it "should return the empty string when joining 0 strings" do
      ctx = Duktape::Context.new
      ctx << ":"
      ctx.join(0)
      str = ctx.require_string(-1)

      str.should eq("")
    end

    it "should raise when not specified separator" do
      ctx = Duktape::Context.new
      ctx << "one"
      ctx << "two"

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.join(2)
      end
    end
  end

  describe "substring" do
    it "should replace the string with a substring" do
      ctx = Duktape::Context.new
      ctx << "take a substring"
      ctx.substring(-1, 0, 3)
      str = ctx.require_string(-1)

      str.should eq("tak")
    end

    it "should return the empty string for invalid indicies" do
      ctx = Duktape::Context.new
      ctx << "string"
      ctx.substring(-1, -1, 2)
      str = ctx.require_string(-1)

      str.should eq("")
    end

    it "should raise if value is not a string" do
      ctx = Duktape::Context.new
      ctx << 123

      expect_raises Duktape::TypeError, /not string/ do
        ctx.substring(-1, 0, 1)
      end
    end
  end

  describe "trim" do
    it "should replace the string by removing whitspace at start/end" do
      ctx = Duktape::Context.new
      ctx << "  something   "
      ctx.trim(-1)
      str = ctx.require_string(-1)

      str.should eq("something")
    end

    it "should raise if value is not a string" do
      ctx = Duktape::Context.new
      ctx << 123

      expect_raises Duktape::TypeError, /not string/ do
        ctx.trim(-1)
      end
    end
  end
end
