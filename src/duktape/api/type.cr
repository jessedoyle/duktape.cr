# type.cr: duktape api type operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  TYPES = {
    LibDUK::Type::None.value      => :none,
    LibDUK::Type::Undefined.value => :undefined,
    LibDUK::Type::Null.value      => :null,
    LibDUK::Type::Boolean.value   => :boolean,
    LibDUK::Type::Number.value    => :number,
    LibDUK::Type::String.value    => :string,
    LibDUK::Type::Object.value    => :object,
    LibDUK::Type::Buffer.value    => :buffer,
    LibDUK::Type::Pointer.value   => :pointer,
    LibDUK::Type::Lightfunc.value => :lightfunc,
  }

  TYPE_TO_NUM = TYPES.invert

  module API::Type
    def check_type(index : Int32, type : Symbol)
      LibDUK.check_type(ctx, index, TYPE_TO_NUM[type]) == 1
    end

    def check_type_mask(index : Int32, mask : UInt32)
      LibDUK.check_type_mask(ctx, index, mask) == 1
    end

    def check_type_mask(index : Int32, mask : LibDUK::TypeMask)
      check_type_mask index, mask.value
    end

    def check_type_mask(index, types : Array(Symbol))
      mask = 0_u32

      types.each do |t|
        check = TYPE_TO_NUM[t]
        mask |= (1 << check).to_u32
      end

      LibDUK.check_type_mask(ctx, index, mask) == 1
    end

    def get_type(index : Int32)
      TYPES[LibDUK.get_type ctx, index]
    end

    def get_type_mask(index : Int32)
      LibDUK.get_type_mask ctx, index
    end

    def is_array(index : Int32)
      LibDUK.is_array(ctx, index) == 1
    end

    def is_boolean(index : Int32)
      LibDUK.is_boolean(ctx, index) == 1
    end

    def is_bound_function(index : Int32)
      LibDUK.is_bound_function(ctx, index) == 1
    end

    def is_buffer(index : Int32)
      LibDUK.is_buffer(ctx, index) == 1
    end

    def is_callable(index : Int32)
      is_function index
    end

    def is_constructor_call
      LibDUK.is_constructor_call(ctx) != 0
    end

    def is_dynamic_buffer(index : Int32)
      LibDUK.is_dynamic_buffer(ctx, index) == 1
    end

    def is_ecmascript_function(index : Int32)
      LibDUK.is_ecmascript_function(ctx, index) == 1
    end

    def is_external_buffer(index : Int32)
      LibDUK.is_external_buffer(ctx, index) == 1
    end

    def is_fixed_buffer(index : Int32)
      LibDUK.is_fixed_buffer(ctx, index) == 1
    end

    def is_function(index : Int32)
      LibDUK.is_function(ctx, index) == 1
    end

    def is_lightfunc(index : Int32)
      LibDUK.is_lightfunc(ctx, index) == 1
    end

    def is_nan(index : Int32)
      LibDUK.is_nan(ctx, index) == 1
    end

    def is_null(index : Int32)
      LibDUK.is_null(ctx, index) == 1
    end

    def is_null_or_undefined(index : Int32)
      mask = [
        :null,
        :undefined,
      ]
      check_type_mask index, mask
    end

    def is_number(index : Int32)
      LibDUK.is_number(ctx, index) == 1
    end

    def is_object(index : Int32)
      LibDUK.is_object(ctx, index) == 1
    end

    def is_object_coercible(index : Int32)
      mask = [
        :boolean,
        :string,
        :object,
        :buffer,
        :pointer,
        :lightfunc,
      ]
      check_type_mask index, mask
    end

    def is_pointer(index : Int32)
      LibDUK.is_pointer(ctx, index) == 1
    end

    def is_primitive(index : Int32)
      mask = [
        :undefined,
        :null,
        :boolean,
        :string,
        :buffer,
        :pointer,
        :lightfunc,
      ]
      check_type_mask index, mask
    end

    def is_proc(index : Int32)
      LibDUK.is_c_function(ctx, index) == 1
    end

    def is_strict_call
      LibDUK.is_strict_call(ctx) == 1
    end

    def is_string(index : Int32)
      LibDUK.is_string(ctx, index) == 1
    end

    def is_thread(index : Int32)
      LibDUK.is_thread(ctx, index) == 1
    end

    def is_undefined(index : Int32)
      LibDUK.is_undefined(ctx, index) == 1
    end
  end
end
