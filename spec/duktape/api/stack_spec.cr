require "../../spec_helper"

describe Duktape::API::Stack do
  describe "check_stack" do
    it "should return true if there is space on stack" do
      ctx = Duktape::Context.new
      fits = ctx.check_stack 10

      fits.should be_true
    end

    it "should return false on Int32::MAX" do
      ctx = Duktape::Context.new
      fits = ctx.check_stack Int32::MAX

      fits.should be_false
    end

    it "should return true on negative input" do
      ctx = Duktape::Context.new
      fits = ctx.check_stack -10

      fits.should be_true
    end
  end

  describe "check_stack_top" do
    it "should return true when space is on stack" do
      ctx = Duktape::Context.new
      fits = ctx.check_stack_top 10

      fits.should be_true
    end

    it "should return false on Int32::MAX" do
      ctx = Duktape::Context.new
      fits = ctx.check_stack_top Int32::MAX

      fits.should be_false
    end
  end

  describe "copy" do
    it "should copy the value at idx_1 to idx_2" do
      ctx = Duktape::Context.new
      ctx << "pos -2"
      ctx << "pos -1"
      ctx.copy -2, -1

      ctx.to_string(-1).should eq("pos -2")
    end

    it "should raise when idx_1 is invalid" do
      ctx = Duktape::Context.new
      ctx << 1

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.copy -2, -1
      end
    end

    it "should raise when idx_2 is invalid" do
      ctx = Duktape::Context.new
      ctx << 1

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.copy -1, -2
      end
    end
  end

  describe "dup" do
    it "should duplicate values on the stack" do
      ctx = Duktape::Context.new
      ctx << "duped"
      ctx.dup -1

      ctx.to_string(-1).should eq("duped")
      ctx.to_string(-2).should eq("duped")
    end

    it "should raise when from index is invalid" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.dup -1
      end
    end
  end

  describe "dup_top" do
    it "should duplicate the top value on the stack" do
      ctx = Duktape::Context.new
      ctx << "duped"
      ctx.dup_top

      ctx.to_string(-1).should eq("duped")
      ctx.to_string(-2).should eq("duped")
    end

    it "should raise if invalid top index" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /stack empty/ do
        ctx.dup_top
      end
    end
  end

  describe "empty?" do
    it "should return true when the stack is empty" do
      ctx = Duktape::Context.new

      ctx.empty?.should be_true
    end

    it "should return false when the stack is not empty" do
      ctx = Duktape::Context.new
      ctx << "val"

      ctx.empty?.should be_false
    end
  end

  describe "get_top" do
    it "should return the index of the stack top" do
      ctx = Duktape::Context.new
      ctx << "STACK0"
      idx = ctx.get_top

      idx.should be_a(Int32)
      idx.should eq(1)
    end
  end

  describe "get_top_index" do
    it "should return LibDUK::INVALID_INDEX when stack is empty" do
      ctx = Duktape::Context.new
      idx = ctx.get_top_index

      idx.should be_a(Int32)
      idx.should eq(LibDUK::INVALID_INDEX)
    end

    it "should return the top index of the stack" do
      ctx = Duktape::Context.new
      ctx << "String1"
      ctx << "String2"
      idx = ctx.get_top_index

      idx.should be_a(Int32)
      idx.should eq(1)
    end
  end

  describe "is_valid_index" do
    it "should return true when data on stack" do
      ctx = Duktape::Context.new
      ctx << "String"

      ctx.is_valid_index(-1).should be_true
    end

    it "should return false when no data on stack" do
      ctx = Duktape::Context.new

      ctx.is_valid_index(-1).should be_false
    end

    it "should be aliased as valid_index?" do
      ctx = Duktape::Context.new

      ctx.valid_index?(-1).should be_false
    end
  end

  describe "insert" do
    it "should insert a value at the specified index" do
      ctx = Duktape::Context.new
      ctx << "left"
      ctx << "right"
      ctx << "inserted"
      ctx.insert -2

      ctx.to_string(-3).should eq("left")
      ctx.to_string(-2).should eq("inserted")
      ctx.to_string(-1).should eq("right")
    end

    it "should raise if invalid top index (empty)" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /stack empty/ do
        ctx.insert -2
      end
    end

    it "should raise if index is invalid" do
      ctx = Duktape::Context.new
      ctx << "left"
      ctx << "right"

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.insert -10
      end
    end
  end

  describe "normalize_index" do
    it "returns LibDUK::INVALID_INDEX on invalid idx" do
      ctx = Duktape::Context.new

      ctx.normalize_index(-1).should eq(LibDUK::INVALID_INDEX)
    end

    it "should normalize the idx relative to bottom of stack" do
      ctx = Duktape::Context.new
      ctx << "1"
      ctx << "2"
      idx = ctx.normalize_index -2

      idx.should eq(0)
    end
  end

  describe "pull" do
    it "should raise when the index is invalid" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.pull -1
      end
    end

    it "removes the value from the index and pushes to stack top" do
      ctx = Duktape::Context.new
      ctx << 0
      ctx << 1
      ctx << 2
      ctx.pull(-3)

      ctx.require_int(-1).should eq(0)
    end
  end

  describe "remove" do
    it "should remove the value at index" do
      ctx = Duktape::Context.new
      ctx << "to be removed"
      ctx.remove -1

      last_stack_type(ctx).should be_js_type(:none)
    end

    it "should raise when index is invalid" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.remove -1
      end
    end
  end

  describe "replace" do
    it "should replace the value at index with top" do
      ctx = Duktape::Context.new
      ctx << 123
      ctx << 234
      ctx << 345
      ctx << "foo"
      ctx.replace -3
      # [ 123, "foo", 345]
      ctx.to_string(-2).should eq("foo")
    end

    it "should raise if stack top is invalid (empty)" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /stack empty/ do
        ctx.replace -2
      end
    end

    it "should raise on invalid index" do
      ctx = Duktape::Context.new
      ctx << "single"

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.replace -2
      end
    end
  end

  describe "require_normalize_index" do
    it "should raise StackError on invalid idx" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.require_normalize_index -1
      end
    end

    it "should normalize the idx relative to bottom of stack" do
      ctx = Duktape::Context.new
      ctx << "1"
      ctx << "2"
      idx = ctx.require_normalize_index -2

      idx.should eq(0)
    end
  end

  describe "require_stack" do
    it "should raise StackError on Int32::MAX" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /stack overflow/ do
        ctx.require_stack Int32::MAX
      end
    end

    it "should return true if there is space on the stack" do
      ctx = Duktape::Context.new

      ctx.require_stack(10).should be_true
    end
  end

  describe "require_stack_top" do
    it "should raise StackError on Int32::MAX" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /stack overflow/ do
        ctx.require_stack_top Int32::MAX
      end
    end

    it "should return true if there is space on the stack" do
      ctx = Duktape::Context.new

      ctx.require_stack_top(10).should be_true
    end
  end

  describe "require_top_index" do
    it "should raise StackError on empty stack" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /stack empty/ do
        ctx.require_top_index
      end
    end

    it "should return the index of the stack top" do
      ctx = Duktape::Context.new
      ctx << "String"

      ctx.require_top_index.should eq(0)
    end
  end

  describe "require_valid_index" do
    it "should raise StackError on invalid idx" do
      ctx = Duktape::Context.new
      ctx << "something"

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.require_valid_index -2
      end
    end

    it "should return true on valid index" do
      ctx = Duktape::Context.new
      ctx << "Filler"

      ctx.require_valid_index(-1).should be_true
    end
  end

  describe "set_top" do
    it "should set the stack top to 0" do
      ctx = Duktape::Context.new
      ctx << "a"
      ctx << 1
      ctx.set_top 0

      ctx.get_top.should eq(0)
    end

    it "should raise StackError on invalid idx" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.set_top -1
      end
    end
  end

  describe "swap" do
    it "should swap values on the stack" do
      ctx = Duktape::Context.new
      ctx << "string"
      ctx << 14
      ctx.swap -1, -2

      ctx.to_int(-2).should eq(14)
      ctx.to_string(-1).should eq("string")
    end

    it "should raise when idx_1 is invalid" do
      ctx = Duktape::Context.new
      ctx << "string"

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.swap -20, -1
      end
    end

    it "should raise when idx_2 is invalid" do
      ctx = Duktape::Context.new
      ctx << "string"

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.swap -1, -20
      end
    end
  end

  describe "swap_top" do
    it "should swap the top value to index on stack" do
      ctx = Duktape::Context.new
      ctx << "bottom"
      ctx << "top"
      ctx.swap_top(-2)

      ctx.to_string(-2).should eq("top")
      ctx.to_string(-1).should eq("bottom")
    end

    it "should raise when stack empty" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /stack empty/ do
        ctx.swap_top(-1)
      end
    end

    it "should raise when index is invalid" do
      ctx = Duktape::Context.new
      ctx << "string"

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.swap_top -10
      end
    end
  end
end
