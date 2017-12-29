require "../../spec_helper"

describe Duktape::API::Object do
  describe "compact" do
    it "should have no external impact" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << 42
      ctx.put_prop_string -2, "meaningOfLife);"
      ctx.compact -1
      val = ctx.json_encode -1

      val.should eq("{\"meaningOfLife);\":42}")
    end
  end

  describe "enum" do
    it "should create an enumerator for object" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx.enum -1, LibDUK::Enum::IncludeNonEnumerable
      ctx.next -1, false
      str = ctx.get_string(-1)

      str.should eq("constructor")
    end

    it "should raise if target is not an object" do
      ctx = Duktape::Context.new
      ctx.push_undefined

      expect_raises Duktape::TypeError, /invalid object/ do
        ctx.enum -1, LibDUK::Enum::IncludeNonEnumerable
      end
    end
  end

  describe "equals" do
    it "should return false if either object has an invalid index" do
      ctx = Duktape::Context.new
      ctx << "equals"
      ctx.dup_top
      val = ctx.equals(-3, -1)

      val.should be_false
    end

    it "should return true if targets are equal" do
      ctx = Duktape::Context.new
      ctx << "equals"
      ctx.dup_top
      val = ctx.equals(-1, -2)

      val.should be_true
    end
  end

  describe "freeze" do
    it "freezes an object on valid index" do
      ctx = Duktape::Context.new
      ctx.eval!("var object = {}; object;")
      ctx.freeze(-1)
      ctx.eval!("Object.isFrozen(object);")
      frozen = ctx.get_boolean(-1)

      frozen.should be_true
    end

    it "raises Duktape::StackError on invalid index" do
      ctx = Duktape::Context.new

      expect_raises(Duktape::StackError, /invalid index/) do
        ctx.freeze(-1)
      end
    end
  end

  describe "get_finalizer" do
    it "should raise on invalid index" do
      ctx = Duktape::Context.new
      ctx << "str"

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.get_finalizer -3
      end
    end

    it "should push undefined to stack on object without finalizer" do
      ctx = Duktape::Context.new
      ctx << "str"
      ctx.get_finalizer -1

      last_stack_type(ctx).should be_js_type(:undefined)
    end
  end

  describe "get_prototype" do
    it "should get the String prototype" do
      ctx = Duktape::Context.new
      ctx.push_global_object
      ctx << "Math"
      ctx.get_prop -2
      ctx.get_prototype -1

      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should raise if target is not an object" do
      ctx = Duktape::Context.new
      ctx.push_null

      expect_raises Duktape::TypeError, /invalid object/ do
        ctx.get_prototype -1
      end
    end
  end

  describe "instanceof" do
    it "should return true if one instanceof(two)" do
      ctx = Duktape::Context.new
      ctx.push_error_object LibDUK::Err.new(101), "Test"
      ctx.get_global_string "Error"

      ctx.instanceof(-2, -1).should be_true
    end

    it "should raise if either index is not an object" do
      ctx = Duktape::Context.new
      ctx << 1
      ctx << 2

      expect_raises Duktape::TypeError, /invalid object/ do
        ctx.instanceof(-2, -1)
      end
    end

    it "should raise on invalid index (one)" do
      ctx = Duktape::Context.new
      ctx.push_object

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.instanceof(-2, -1)
      end
    end

    it "should raise on invalid index (two)" do
      ctx = Duktape::Context.new
      ctx.push_object

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.instanceof(-1, -2)
      end
    end
  end

  describe "next" do
    it "should return true until enumerated set" do
      ctx = Duktape::Context.new
      json = <<-JSON
        {
          "foo": 1,
          "bar": -2
        }
      JSON

      ctx << json
      ctx.json_decode -1
      ctx.enum -1, LibDUK::Enum::OwnPropertiesOnly
      count = 0

      while ctx.next(-1)
        count += 1
        ctx.pop
      end

      count.should eq(2)
    end
  end

  describe "samevalue" do
    it "should return true if two values are the same" do
      ctx = Duktape::Context.new
      ctx << "one"
      ctx << "one"
      val = ctx.samevalue(-1, -2)

      val.should be_true
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new
      ctx << "one"
      ctx << "one"
      val = ctx.samevalue(-1, -3)

      val.should be_false
    end
  end

  describe "seal" do
    it "seals the object on valid index" do
      ctx = Duktape::Context.new
      ctx.eval!("var object = {}; object;")
      ctx.seal(-1)
      ctx.eval!("Object.isSealed(object);")
      sealed = ctx.get_boolean(-1)

      sealed.should be_true
    end

    it "raises Duktape::StackError on invalid index" do
      ctx = Duktape::Context.new

      expect_raises(Duktape::StackError, /invalid index/) do
        ctx.seal(-1)
      end
    end
  end

  describe "set_finalizer" do
    it "should set the finalizer of an object" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx.push_proc(1) do |ptr|
        env = Duktape::Context.new ptr
        env.return 0
      end
      ctx.set_finalizer(-2)

      last_stack_type(ctx).should be_js_type(:object)
    end
  end

  describe "set_global_object" do
    it "should replace the global object with one on stack top" do
      ctx = Duktape::Context.new
      ctx.push_global_object
      ctx << "Duktape"
      ctx.get_prop(-2)
      ctx.set_global_object

      expect_raises Duktape::ReferenceError, /identifier 'Duktape' undefined/ do
        ctx.eval_string! <<-JS
          Duktape.version;
        JS
      end
    end

    it "should raise on invalid object" do
      ctx = Duktape::Context.new
      ctx.push_null

      expect_raises Duktape::TypeError, /invalid object/ do
        ctx.set_global_object
      end
    end
  end

  describe "set_length" do
    it "should set the length of an object" do
      ctx = Duktape::Context.new
      ctx.push_array
      ctx.set_length -1, 2

      ctx.get_length(-1).should eq(2)
    end

    it "should raise on invalid object" do
      ctx = Duktape::Context.new
      ctx.push_null

      expect_raises Duktape::TypeError, /invalid object/ do
        ctx.set_length -1, 2
      end
    end
  end

  describe "set_prototype" do
    it "sets an object's prototype" do
      ctx = Duktape::Context.new
      ctx.push_global_object
      ctx << "Math"
      ctx.get_prop -2
      ctx.push_global_object
      ctx << "Duktape"
      ctx.get_prop(-2)
      ctx.set_prototype -4
      ctx.pop_n(3)
    end

    it "should raise on invalid object" do
      ctx = Duktape::Context.new
      ctx.push_null

      expect_raises Duktape::TypeError, /invalid object/ do
        ctx.set_prototype -1
      end
    end
  end

  describe "strict_equals" do
    it "should return true if two objects are equal" do
      ctx = Duktape::Context.new
      ctx << "one"
      ctx.dup_top
      val = ctx.strict_equals(-1, -2)

      val.should be_true
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new
      ctx << "one"
      ctx.dup_top
      val = ctx.strict_equals(-1, -3)

      val.should be_false
    end
  end
end
