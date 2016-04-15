# compile.cr: duktape compilation operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Compile
    # NOTE: These methods are all equivalent to the Duktape
    # `pcompile_xxx` functions because we wish to safely return
    # from errors.
    def compile(flags = 0_u32)
      require_valid_index -2 # Source and filename
      LibDUK.compile_raw ctx, nil, 0, (flags | LibDUK::COMPILE_SAFE)
    end

    def compile(str : String, flags : UInt32 = 0)
      compile_string str, flags
    end

    def compile!(flags = 0_u32)
      err = compile flags
      raise_error err
    end

    def compile!(str : String, flags = 0_u32)
      compile_string! str, flags
    end

    def compile_file(path : String, flags = 0_u32)
      push_string_file path
      push_string path
      LibDUK.compile_raw ctx, nil, 0, (flags | LibDUK::COMPILE_SAFE)
    end

    def compile_file!(path : String, flags = 0_u32)
      err = compile_file path, flags
      raise_error err
    end

    def compile_lstring(src : String, length : Int32, flags = 0_u32)
      flags |= LibDUK::COMPILE_SAFE |
        LibDUK::COMPILE_NOSOURCE
      push_string __FILE__
      LibDUK.compile_raw ctx, src, length, flags
    end

    def compile_lstring!(src : String, length : Int32, flags : UInt32 = 0_u32)
      err = compile_lstring src, length, flags
      raise_error err
    end

    def compile_lstring_filename(src : String, length : Int32, flags = 0_u32)
      require_valid_index -1 # filename
      flags |= LibDUK::COMPILE_SAFE |
        LibDUK::COMPILE_NOSOURCE
      LibDUK.compile_raw ctx, src, length, flags
    end

    def compile_lstring_filename!(src : String, length : Int32, flags = 0_u32)
      err = compile_lstring_filename src, length, flags
      raise_error err
    end

    def compile_string(src : String, flags = 0_u32)
      flags |= LibDUK::COMPILE_SAFE |
        LibDUK::COMPILE_NOSOURCE |
        LibDUK::COMPILE_STRLEN
      push_string __FILE__
      LibDUK.compile_raw ctx, src, 0, flags
    end

    def compile_string!(src : String, flags = 0_u32)
      err = compile_string src, flags
      raise_error err
    end

    def compile_string_filename(src : String, flags = 0_u32)
      require_valid_index -1 # filename
      flags |= LibDUK::COMPILE_SAFE |
        LibDUK::COMPILE_NOSOURCE |
        LibDUK::COMPILE_STRLEN
      LibDUK.compile_raw ctx, src, 0, flags
    end

    def compile_string_filename!(src : String, flags = 0_u32)
      err = compile_string_filename src, flags
      raise_error err
    end

    def dump_function
      LibDUK.dump_function ctx
    end

    def load_function
      require_buffer -1 # Stack Top
      LibDUK.load_function ctx
    end
  end
end
