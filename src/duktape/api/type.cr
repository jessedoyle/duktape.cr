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
    def check_type(index : LibDUK::Index, type : Symbol)
      LibDUK.check_type(ctx, index, TYPE_TO_NUM[type]) == 1
    end

    def check_type_mask(index : LibDUK::Index, mask : UInt32)
      LibDUK.check_type_mask(ctx, index, mask) == 1
    end

    def check_type_mask(index : LibDUK::Index, mask : LibDUK::TypeMask)
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

    def get_type(index : LibDUK::Index)
      TYPES[LibDUK.get_type ctx, index]
    end

    def get_type_mask(index : LibDUK::Index)
      LibDUK.get_type_mask ctx, index
    end

    def is_array(index : LibDUK::Index)
      LibDUK.is_array(ctx, index) == 1
    end

    def is_boolean(index : LibDUK::Index)
      LibDUK.is_boolean(ctx, index) == 1
    end

    def is_bound_function(index : LibDUK::Index)
      LibDUK.is_bound_function(ctx, index) == 1
    end

    def is_buffer(index : LibDUK::Index)
      LibDUK.is_buffer(ctx, index) == 1
    end

    def is_buffer_data(index : LibDUK::Index)
      LibDUK.is_buffer_data(ctx, index) == 1
    end

    def is_callable(index : LibDUK::Index)
      is_function index
    end

    def is_constructable(index : LibDUK::Index)
      LibDUK.is_constructable(ctx, index) == 1
    end

    def is_constructor_call
      LibDUK.is_constructor_call(ctx) != 0
    end

    def is_dynamic_buffer(index : LibDUK::Index)
      LibDUK.is_dynamic_buffer(ctx, index) == 1
    end

    def is_ecmascript_function(index : LibDUK::Index)
      LibDUK.is_ecmascript_function(ctx, index) == 1
    end

    def is_external_buffer(index : LibDUK::Index)
      LibDUK.is_external_buffer(ctx, index) == 1
    end

    def is_fixed_buffer(index : LibDUK::Index)
      LibDUK.is_fixed_buffer(ctx, index) == 1
    end

    def is_function(index : LibDUK::Index)
      LibDUK.is_function(ctx, index) == 1
    end

    def is_lightfunc(index : LibDUK::Index)
      LibDUK.is_lightfunc(ctx, index) == 1
    end

    def is_nan(index : LibDUK::Index)
      LibDUK.is_nan(ctx, index) == 1
    end

    def is_null(index : LibDUK::Index)
      LibDUK.is_null(ctx, index) == 1
    end

    def is_null_or_undefined(index : LibDUK::Index)
      mask = [
        :null,
        :undefined,
      ]
      check_type_mask index, mask
    end

    def is_number(index : LibDUK::Index)
      LibDUK.is_number(ctx, index) == 1
    end

    def is_object(index : LibDUK::Index)
      LibDUK.is_object(ctx, index) == 1
    end

    def is_object_coercible(index : LibDUK::Index)
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

    def is_pointer(index : LibDUK::Index)
      LibDUK.is_pointer(ctx, index) == 1
    end

    def is_primitive(index : LibDUK::Index)
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

    def is_proc(index : LibDUK::Index)
      LibDUK.is_c_function(ctx, index) == 1
    end

    def is_strict_call
      LibDUK.is_strict_call(ctx) == 1
    end

    def is_string(index : LibDUK::Index)
      LibDUK.is_string(ctx, index) == 1
    end

    def is_symbol(index : LibDUK::Index)
      LibDUK.is_symbol(ctx, index) == 1
    end

    def is_thread(index : LibDUK::Index)
      LibDUK.is_thread(ctx, index) == 1
    end

    def is_undefined(index : LibDUK::Index)
      LibDUK.is_undefined(ctx, index) == 1
    end
  end
end
