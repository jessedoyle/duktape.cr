require "../../spec_helper"

# NOTE: All the following methods raise on invalid index
# using `ctx.require_valid_index`. This mechanism is
# adequately tested in `stack_spec`, so there is no need
# to test that functionality here.

describe Duktape::API::Prop do
  flags = LibDUK::DefProp::HaveValue |
          LibDUK::DefProp::HaveWritable |
          LibDUK::DefProp::Writable |
          LibDUK::DefProp::HaveEnumerable |
          LibDUK::DefProp::HaveConfigurable |
          LibDUK::DefProp::Configurable

  describe "def_prop" do
    it "should define a property on an object" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "foo"
      ctx << "key"
      ctx << 123
      before = ctx.get_top
      ctx.def_prop(-4, flags)
      after = ctx.get_top

      # Check for a property named `key`
      ctx << "key"
      val = ctx.get_prop(-3)

      before.should eq(4)
      after.should eq(2)
      val.should be_true
    end

    it "should raise when value is not object coercible" do
      ctx = Duktape::Context.new
      ctx.push_undefined
      ctx << "foo"
      ctx << "key"
      ctx << 123

      expect_raises Duktape::TypeError, /not object/ do
        ctx.def_prop(-4, flags)
      end
    end
  end

  describe "del_prop" do
    it "should return true on success" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "foo"
      ctx << "my_prop"
      # Make prop
      ctx.def_prop(-3, flags)
      ctx << "my_prop"
      # Delete prop
      val = ctx.del_prop(-2)
      ctx << "my_prop"
      # Ensure prop deleted
      prop = ctx.get_prop(-2)

      prop.should be_false
      val.should be_true
    end

    it "should return true if property doesn't exist" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "foo"
      ctx << "prop_1"
      ctx.def_prop(-3, flags)
      ctx << "prop_2"
      val = ctx.del_prop(-2)

      val.should be_true
    end

    it "should raise when value is not object coercible" do
      ctx = Duktape::Context.new
      ctx.push_undefined
      ctx << "foo"
      ctx << "key"
      ctx << 123

      expect_raises Duktape::TypeError, /not object/ do
        ctx.del_prop(-4)
      end
    end
  end

  describe "del_prop_index" do
    it "should delete the property at index returning true" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "obj"
      ctx << "123"
      ctx.def_prop(-3, flags)
      val = ctx.del_prop_index(-1, 123_u32)
      prop = ctx.get_prop_index(-1, 123_u32)

      prop.should be_false
      val.should be_true
    end

    it "should return true if property doesn't exist" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "obj"
      ctx << "123"
      ctx.def_prop(-3, flags)
      val = ctx.del_prop_index(-1, 456_u32)

      val.should be_true
    end

    it "should raise when value is not object coercible" do
      ctx = Duktape::Context.new
      ctx.push_null
      ctx << "foo"
      ctx << "key"
      ctx << 123

      expect_raises Duktape::TypeError, /not object/ do
        ctx.del_prop_index(-4, 123_u32)
      end
    end
  end

  describe "del_prop_string" do
    it "should delete the property passed and return true" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "obj"
      ctx << "prop_string"
      ctx.def_prop(-3, flags)
      val = ctx.del_prop_string(-1, "prop_string")
      prop = ctx.get_prop_string(-1, "prop_string")

      prop.should be_false
      val.should be_true
    end

    it "should return true if property doesn't exist" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "obj"
      ctx << "abc"
      ctx.def_prop(-3, flags)
      val = ctx.del_prop_string(-1, "def")

      val.should be_true
    end

    it "should raise when value is not object coercible" do
      ctx = Duktape::Context.new
      ctx.push_undefined
      ctx << "foo"
      ctx << "bar"

      expect_raises Duktape::TypeError, /not object/ do
        ctx.del_prop_string(-3, "bar")
      end
    end
  end

  describe "get_global_string" do
    it "should return true if the gloabl exists" do
      ctx = Duktape::Context.new
      ctx << "foo"
      ctx << "GLOBAL"
      ctx.put_global_string("bar")
      ctx << "something else"
      val = ctx.get_global_string("bar")
      top = ctx.get_string(-1)

      top.should eq("GLOBAL")
      val.should be_true
    end

    it "should return false when global doesn't exist" do
      ctx = Duktape::Context.new
      val = ctx.get_global_string("ABC")

      val.should be_false
    end
  end

  describe "get_prop" do
    it "should replace the prop value with key on stack if prop exists" do
      ctx = Duktape::Context.new
      ctx.push_global_object   # [ global ]
      ctx << "Math"            # [ global "Math" ]
      val_1 = ctx.get_prop(-2) # [ global Math ]
      ctx << "PI"              # [ global Math "PI" ]
      val_2 = ctx.get_prop(-2) # [ global Math PI ]
      pi = ctx.get_number(-1)
      ctx.pop_3

      val_1.should be_true
      val_2.should be_true
      pi.round(2).should eq(3.14)
    end

    it "replace the key with undefined and return false if prop doesn't exist" do
      ctx = Duktape::Context.new
      ctx.push_global_object
      ctx << "Foo"
      val = ctx.get_prop(-2)

      last_stack_type(ctx).should be_js_type(:undefined)
      val.should be_false
    end

    it "should raise if value is not object coercible" do
      ctx = Duktape::Context.new
      ctx.push_undefined

      expect_raises Duktape::TypeError, /not object/ do
        ctx.get_prop(-1)
      end
    end
  end

  describe "get_prop_index" do
    it "should return true if the prop exists" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "key"
      ctx.put_prop_index(-2, 123_u32)
      val = ctx.get_prop_index(-1, 123_u32)
      top = ctx.require_string(-1)

      top.should eq("key")
      val.should be_true
    end

    it "should return false if the prop doesn't exist" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "key"
      ctx.put_prop_index(-2, 123_u32)
      val = ctx.get_prop_index(-1, 456_u32)

      val.should be_false
      last_stack_type(ctx).should be_js_type(:undefined)
    end

    it "should raise when valus is not object coercible" do
      ctx = Duktape::Context.new
      ctx.push_null
      ctx << "key"

      expect_raises Duktape::TypeError, /not object/ do
        ctx.get_prop_index(-2, 123_u32)
      end
    end
  end

  describe "get_prop_string" do
    it "should return true if the prop exists" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "key"
      ctx.put_prop_string(-2, "my_prop")
      val = ctx.get_prop_string(-1, "my_prop")
      top = ctx.require_string(-1)

      top.should eq("key")
      val.should be_true
    end

    it "should return false if the prop doesn't exist" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "key"
      ctx.put_prop_string(-2, "a_string")
      val = ctx.get_prop_string(-1, "my_string")

      val.should be_false
      last_stack_type(ctx).should be_js_type(:undefined)
    end

    it "should raise if value is not object coercible" do
      ctx = Duktape::Context.new
      ctx.push_null
      ctx << "key"

      expect_raises Duktape::TypeError, /not object/ do
        ctx.get_prop_string(-2, "foo")
      end
    end
  end

  describe "has_prop" do
    it "should return true if the property exists" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "key"
      ctx.put_prop_string(-2, "foo")
      ctx << "foo"
      val = ctx.has_prop(-2)

      val.should be_true
      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should return false if property doesn't exist" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "key"
      ctx.put_prop_string(-2, "abc")
      ctx << "def"
      val = ctx.has_prop(-2)

      val.should be_false
      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should raise if value is not an object" do
      ctx = Duktape::Context.new
      ctx << "not object but object coercible"
      ctx << "key"

      expect_raises Duktape::TypeError, /invalid object/ do
        ctx.has_prop(-2)
      end
    end
  end

  describe "has_prop_index" do
    it "should return true when prop exists" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "key"
      ctx.put_prop_index(-2, 123_u32)
      val = ctx.has_prop_index(-1, 123_u32)

      val.should be_true
      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should return false when prop doesn't exist" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "key"
      ctx.put_prop_index(-2, 123_u32)
      val = ctx.has_prop_index(-1, 456_u32)

      val.should be_false
      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should raise if value is not an object" do
      ctx = Duktape::Context.new
      ctx << "not object but object coercible"
      ctx << "key"

      expect_raises Duktape::TypeError, /invalid object/ do
        ctx.has_prop_index(-2, 123_u32)
      end
    end
  end

  describe "has_prop_string" do
    it "should return true when property exists" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "val"
      ctx.put_prop_string(-2, "foo")
      val = ctx.has_prop_string(-1, "foo")

      val.should be_true
      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should return false when property doesn't exist" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "val"
      ctx.put_prop_string(-2, "foo")
      val = ctx.has_prop_string(-1, "bar")

      val.should be_false
      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should raise when value is not an object" do
      ctx = Duktape::Context.new
      ctx << "not object but object coercible"
      ctx << "key"

      expect_raises Duktape::TypeError, /invalid object/ do
        ctx.has_prop_string(-2, "foo")
      end
    end
  end

  describe "put_global_string" do
    it "should put a property named key to the global object" do
      ctx = Duktape::Context.new
      ctx << "bar"
      val = ctx.put_global_string("foo")
      ctx.get_global_string("foo")
      str = ctx.require_string(-1)

      val.should be_true
      str.should eq("bar")
    end

    it "should raise if stack is empty" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.put_global_string("abc")
      end
    end
  end

  describe "put_global_heapptr" do
    it "should put a property on the global object from a Duktape heap pointer" do
      ctx = Duktape::Context.new
      ctx << "string"
      ptr = ctx.get_heapptr(-1)
      val = ctx.put_global_heapptr(ptr)
      ctx.get_global_string("string")
      str = ctx.require_string(-1)

      str.should eq("string")
      val.should be_true
    end

    it "should raise if the stack is empty" do
      ctx = Duktape::Context.new

      expect_raises Duktape::StackError, /invalid index/ do
        ctx.put_global_heapptr(Pointer(Void).null)
      end
    end
  end

  describe "put_prop" do
    it "should put a prop key with value val and return true" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "val"
      ctx << "key"
      val = ctx.put_prop(-3)

      val.should be_true
      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should raise if value is not object coercible" do
      ctx = Duktape::Context.new
      ctx.push_undefined
      ctx << "key"
      ctx << "val"

      expect_raises Duktape::TypeError, /not object/ do
        ctx.put_prop(-3)
      end
    end
  end

  describe "put_prop_index" do
    it "should put a property corresponding to index" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "val"
      val = ctx.put_prop_index(-2, 123_u32)

      val.should be_true
      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should raise if value is not object coercible" do
      ctx = Duktape::Context.new
      ctx.push_null
      ctx << "val"

      expect_raises Duktape::TypeError, /not object/ do
        ctx.put_prop_index(-2, 123_u32)
      end
    end
  end

  describe "put_prop_string" do
    it "should put a property with value and key" do
      ctx = Duktape::Context.new
      ctx.push_object
      ctx << "value"
      val = ctx.put_prop_string(-2, "key")

      val.should be_true
      last_stack_type(ctx).should be_js_type(:object)
    end

    it "should raise if value is not object coercible" do
      ctx = Duktape::Context.new
      ctx.push_undefined
      ctx << "value"

      expect_raises Duktape::TypeError, /not object/ do
        ctx.put_prop_string(-2, "key")
      end
    end
  end
end
