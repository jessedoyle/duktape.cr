require "../../spec_helper"

describe Duktape::API::Type do
  describe "check_type" do
    it "should return true if value is of type" do
      ctx = Duktape::Context.new
      ctx << false
      val = ctx.check_type -1, :boolean

      val.should be_a(Bool)
      val.should be_true
    end

    it "should return false if value is not of type" do
      ctx = Duktape::Context.new
      ctx << "string"

      ctx.check_type(-1, :null).should be_false
    end

    it "should return true on invalid index and :none" do
      ctx = Duktape::Context.new

      ctx.check_type(-1, :none).should be_true
    end
  end

  describe "check_type_mask" do
    context "with Array(Symbol)" do
      it "should return true if type is in the supplied array" do
        ctx = Duktape::Context.new
        ctx << "string"

        ctx.check_type_mask(-1, [:null, :string]).should be_true
      end

      it "should return false for an empty array" do
        ctx = Duktape::Context.new
        arr = [] of Symbol

        ctx.check_type_mask(-1, arr).should be_false
      end

      it "should return true on invalid index and :none" do
        ctx = Duktape::Context.new

        ctx.check_type_mask(-1, [:none]).should be_true
      end
    end

    context "with LibDUK::TypeMask" do
      it "should return true when type matches" do
        ctx = Duktape::Context.new
        mask = LibDUK::TypeMask::Null | LibDUK::TypeMask::String
        ctx.push_null

        ctx.check_type_mask(-1, mask).should be_true
      end
    end
  end

  describe "get_type" do
    it "should get the type of a value on the stack" do
      ctx = Duktape::Context.new
      ctx << 1
      ctx << "string"
      ctx << true
      ctx.push_object
      ctx.push_undefined
      ctx.push_null

      ctx.get_type(-1).should eq(:null)
      ctx.get_type(-2).should eq(:undefined)
      ctx.get_type(-3).should eq(:object)
      ctx.get_type(-4).should eq(:boolean)
      ctx.get_type(-5).should eq(:string)
      ctx.get_type(-6).should eq(:number)
    end

    it "should return :none on invalid index" do
      ctx = Duktape::Context.new

      ctx.get_type(-1).should eq(:none)
    end
  end

  describe "get_type_mask" do
    it "should return a UInt32 matching the type mask" do
      ctx = Duktape::Context.new
      ctx << 1
      num = ctx.get_type_mask -1

      num.should be_a(UInt32)
      num.should eq(LibDUK::TypeMask::Number.value)
    end

    it "should return LibDUK::TypeMask::None on invalid index" do
      ctx = Duktape::Context.new

      ctx.get_type_mask(-1).should eq(LibDUK::TypeMask::None.value)
    end
  end

  describe "is_array" do
    it "should return true if element is an array" do
      ctx = Duktape::Context.new
      ctx.push_array

      ctx.is_array(-1).should be_true
    end

    it "should return false if element is not an array" do
      ctx = Duktape::Context.new
      ctx << "test"

      ctx.is_array(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_array(-1).should be_false
    end
  end

  describe "is_boolean" do
    it "should return true if element is a boolean" do
      ctx = Duktape::Context.new
      ctx << true

      ctx.is_boolean(-1).should be_true
    end

    it "should return false if element is not a boolean" do
      ctx = Duktape::Context.new
      ctx << "test"

      ctx.is_boolean(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_boolean(-1).should be_false
    end
  end

  describe "is_bound_function" do
    it "should return false if not a bound function" do
      ctx = Duktape::Context.new
      ctx << "not function"

      ctx.is_bound_function(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_bound_function(-1).should be_false
    end
  end

  describe "is_buffer" do
    it "should return true if element is a buffer" do
      ctx = Duktape::Context.new
      ctx.push_buffer 1

      ctx.is_buffer(-1).should be_true
    end

    it "should return false if element is not a buffer" do
      ctx = Duktape::Context.new
      ctx.push_buffer 2, false
      ctx.push_buffer_object -1, 1, 2, LibDUK::BufObj::ArrayBuffer

      ctx.is_buffer(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_buffer(-1).should be_false
    end
  end

  describe "is_buffer_data" do
    it "should return true if element is a plainbuffer" do
      ctx = Duktape::Context.new
      ctx.push_buffer 1

      ctx.is_buffer_data(-1).should be_true
    end

    it "should return true if element is a buffer object" do
      ctx = Duktape::Context.new
      ctx.push_buffer 2, false
      ctx.push_buffer_object -1, 1, 2, LibDUK::BufObj::ArrayBuffer

      ctx.is_buffer_data(-1).should be_true
    end

    it "should return false on a non-buffer type" do
      ctx = Duktape::Context.new
      ctx.push_boolean true

      ctx.is_buffer_data(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_buffer_data(-1).should be_false
    end
  end

  describe "is_callable" do
    it "should return true if element is callable" do
      ctx = Duktape::Context.new
      ctx.eval_string! <<-JS
        var func = function callable(){
          1 + 1;
        };

        func;
      JS

      ctx.is_callable(-1).should be_true
    end

    it "should return false if the element is not callable" do
      ctx = Duktape::Context.new
      ctx << 1

      ctx.is_callable(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_callable(-1).should be_false
    end
  end

  describe "is_constructable" do
    context "with an invalid index" do
      it "returns false" do
        ctx = Duktape::Context.new

        ctx.is_constructable(-1).should be_false
      end
    end

    context "with a valid index" do
      it "returns true if the function is constructable" do
        ctx = Duktape::Context.new
        ctx.eval!("var func = function(){}; func;")

        ctx.is_constructable(-1).should be_true
      end
    end
  end

  describe "is_dynamic_buffer" do
    it "should return true if element is a dynamic buffer" do
      ctx = Duktape::Context.new
      ctx.push_dynamic_buffer 1

      ctx.is_dynamic_buffer(-1).should be_true
    end

    it "should return false for static buffers" do
      ctx = Duktape::Context.new
      ctx.push_buffer 1, false

      ctx.is_dynamic_buffer(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_dynamic_buffer(-1).should be_false
    end
  end

  describe "is_ecmascript_function" do
    it "should return true for ECMAScript function" do
      ctx = Duktape::Context.new
      ctx.eval_string! <<-JS
        var func = function ecma(){
          1 + 1;
        };

        func;
      JS

      ctx.is_ecmascript_function(-1).should be_true
    end

    it "should return false when not a function" do
      ctx = Duktape::Context.new
      ctx << 1

      ctx.is_ecmascript_function(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_ecmascript_function(-1).should be_false
    end
  end

  describe "is_external_buffer" do
    it "should return true if buffer is external" do
      ctx = Duktape::Context.new
      ctx.push_external_buffer

      ctx.is_external_buffer(-1).should be_true
    end

    it "should return false for non-external buffer" do
      ctx = Duktape::Context.new
      ctx.push_dynamic_buffer 2

      ctx.is_external_buffer(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_external_buffer(-1).should be_false
    end
  end

  describe "is_fixed_buffer" do
    it "should return true when element is a fixed buffer" do
      ctx = Duktape::Context.new
      ctx.push_buffer 1, false

      ctx.is_fixed_buffer(-1).should be_true
    end

    it "should return false when dynamic buffer" do
      ctx = Duktape::Context.new
      ctx.push_buffer 1, true

      ctx.is_fixed_buffer(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_fixed_buffer(-1).should be_false
    end
  end

  describe "is_function" do
    it "should return true for function" do
      ctx = Duktape::Context.new
      ctx.eval_string! <<-JS
        var func = function(){
          1 + 1;
        };

        func;
      JS

      ctx.is_function(-1).should be_true
    end

    it "should return false when not a function" do
      ctx = Duktape::Context.new
      ctx << 1

      ctx.is_function(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_function(-1).should be_false
    end
  end

  describe "is_nan" do
    it "should return true when element is NaN" do
      ctx = Duktape::Context.new
      ctx.push_nan

      ctx.is_nan(-1).should be_true
    end

    it "should return false when not NaN" do
      ctx = Duktape::Context.new
      ctx << 3.14

      ctx.is_nan(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_nan(-1).should be_false
    end
  end

  describe "is_null" do
    it "should return true when element is null" do
      ctx = Duktape::Context.new
      ctx.push_null

      ctx.is_null(-1).should be_true
    end

    it "should return false when not null" do
      ctx = Duktape::Context.new
      ctx.push_undefined

      ctx.is_null(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_null(-1).should be_false
    end
  end

  describe "is_null_or_undefined" do
    it "should return true when element is null" do
      ctx = Duktape::Context.new
      ctx.push_null

      ctx.is_null_or_undefined(-1).should be_true
    end

    it "should return true when element is undefined" do
      ctx = Duktape::Context.new
      ctx.push_undefined

      ctx.is_null_or_undefined(-1).should be_true
    end

    it "should return false when not null or undefined" do
      ctx = Duktape::Context.new
      ctx << 1

      ctx.is_null_or_undefined(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_null_or_undefined(-1).should be_false
    end
  end

  describe "is_number" do
    it "should return true when element is a number" do
      ctx = Duktape::Context.new
      ctx << 3.14

      ctx.is_number(-1).should be_true
    end

    it "should return false when not a number" do
      ctx = Duktape::Context.new
      ctx << "string"

      ctx.is_number(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_number(-1).should be_false
    end
  end

  describe "is_object" do
    it "should return true when element is an object" do
      ctx = Duktape::Context.new
      ctx.push_object

      ctx.is_object(-1).should be_true
    end

    it "should return false when not an object" do
      ctx = Duktape::Context.new
      ctx << "string"

      ctx.is_object(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_object(-1).should be_false
    end
  end

  describe "is_object_coercible" do
    it "should return true if object coercible" do
      ctx = Duktape::Context.new
      ctx << "object coercible"

      ctx.is_object_coercible(-1).should be_true
    end

    it "should return false if null" do
      ctx = Duktape::Context.new
      ctx.push_null

      ctx.is_object_coercible(-1).should be_false
    end

    it "should return false if undefined" do
      ctx = Duktape::Context.new
      ctx.push_undefined

      ctx.is_object_coercible(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_object_coercible(-1).should be_false
    end
  end

  describe "is_pointer" do
    it "should return true if element is a pointer" do
      ptr = Pointer(Void).malloc 1
      ctx = Duktape::Context.new
      ctx.push_pointer ptr

      ctx.is_pointer(-1).should be_true
    end

    it "should return false when not pointer" do
      ctx = Duktape::Context.new
      ctx << "not pointer"

      ctx.is_pointer(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_pointer(-1).should be_false
    end
  end

  describe "is_primitive" do
    it "should return true when primitive type" do
      ctx = Duktape::Context.new
      ctx << "primitive"

      ctx.is_primitive(-1).should be_true
    end

    it "should return false on Object" do
      ctx = Duktape::Context.new
      ctx.push_object

      ctx.is_primitive(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_primitive(-1).should be_false
    end
  end

  describe "is_strict_call" do
    it "should return true from user code" do
      ctx = Duktape::Context.new

      ctx.is_strict_call.should be_true
    end
  end

  describe "is_string" do
    it "should return true when element is a string" do
      ctx = Duktape::Context.new
      ctx << "string"

      ctx.is_string(-1).should be_true
    end

    it "should return false when not a string" do
      ctx = Duktape::Context.new
      ctx << 3.14

      ctx.is_string(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_string(-1).should be_false
    end
  end

  describe "is_symbol" do
    it "should return true when element is a symbol" do
      ctx = Duktape::Context.new
      ctx.eval("Symbol('test');")

      ctx.is_symbol(-1).should be_true
    end

    it "should return false when not a symbol" do
      ctx = Duktape::Context.new
      ctx << 3.14

      ctx.is_string(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_symbol(-1).should be_false
    end
  end

  describe "is_thread" do
    it "should return true when element is a thread" do
      ctx = Duktape::Context.new
      ctx.push_thread

      ctx.is_thread(-1).should be_true
    end

    it "should return false when not a thread" do
      ctx = Duktape::Context.new
      ctx << -1

      ctx.is_thread(-1).should be_false
    end

    it "should return false when invalid index" do
      ctx = Duktape::Context.new

      ctx.is_thread(-1).should be_false
    end
  end

  describe "is_undefined" do
    it "should return true when element is undefined" do
      ctx = Duktape::Context.new
      ctx.push_undefined

      ctx.is_undefined(-1).should be_true
    end

    it "should return false when not undefined" do
      ctx = Duktape::Context.new
      ctx.push_null

      ctx.is_undefined(-1).should be_false
    end

    it "should return false on invalid index" do
      ctx = Duktape::Context.new

      ctx.is_undefined(-1).should be_false
    end
  end
end
