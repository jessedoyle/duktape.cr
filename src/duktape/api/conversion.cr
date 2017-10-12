# conversion.cr: duktape api conversion operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Conversion
    def base64_decode(index : LibDUK::Index)
      require_valid_index index
      require_string index
      LibDUK.base64_decode ctx, index
    end

    def base64_encode(index : LibDUK::Index)
      require_valid_index index
      ptr = LibDUK.base64_encode ctx, index
      String.new ptr
    end

    def hex_decode(index : LibDUK::Index)
      require_valid_index index
      require_string index
      LibDUK.hex_decode ctx, index
    end

    def hex_encode(index : LibDUK::Index)
      require_valid_index index
      ptr = LibDUK.hex_encode ctx, index
      String.new ptr
    end

    def json_decode(index : LibDUK::Index)
      require_valid_index index
      require_string index
      LibDUK.json_decode ctx, index
    end

    def json_encode(index : LibDUK::Index)
      require_valid_index index
      ptr = LibDUK.json_encode ctx, index
      String.new ptr
    end
  end
end
