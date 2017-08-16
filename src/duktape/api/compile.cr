# compile.cr: duktape compilation operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Compile
    include Support::File

    # NOTE: These methods are all equivalent to the Duktape
    # `pcompile_xxx` functions because we wish to safely return
    # from errors.
    def compile
      require_valid_index -2 # Source and filename
      options = LibDUK::Compile.new(2_u32) |
                LibDUK::Compile::Safe
      LibDUK.compile_raw ctx, nil, 0, options
    end

    def compile(str : String)
      compile_string str
    end

    def compile!
      err = compile
      raise_error err
    end

    def compile!(str : String)
      compile_string! str
    end

    def compile_file(str : String)
      compile read_file(str)
    end

    def compile_file!(str : String)
      compile! read_file(str)
    end

    def compile_lstring(src : String, length : Int32)
      options = LibDUK::Compile.new(0_u32) |
                LibDUK::Compile::Safe |
                LibDUK::Compile::NoSource |
                LibDUK::Compile::NoFilename
      LibDUK.compile_raw ctx, src, length, options
    end

    def compile_lstring!(src : String, length : Int32)
      err = compile_lstring src, length
      raise_error err
    end

    def compile_lstring_filename(src : String, length : Int32)
      require_valid_index -1 # filename
      options = LibDUK::Compile.new(1_u32) |
                LibDUK::Compile::Safe |
                LibDUK::Compile::NoSource
      LibDUK.compile_raw ctx, src, length, options
    end

    def compile_lstring_filename!(src : String, length : Int32)
      err = compile_lstring_filename src, length
      raise_error err
    end

    def compile_string(src : String)
      options = LibDUK::Compile.new(0_u32) |
                LibDUK::Compile::Safe |
                LibDUK::Compile::NoSource |
                LibDUK::Compile::StrLen |
                LibDUK::Compile::NoFilename
      LibDUK.compile_raw ctx, src, 0, options
    end

    def compile_string!(src : String)
      err = compile_string src
      raise_error err
    end

    def compile_string_filename(src : String)
      require_valid_index -1 # filename
      options = LibDUK::Compile.new(1_u32) |
                LibDUK::Compile::Safe |
                LibDUK::Compile::NoSource |
                LibDUK::Compile::StrLen
      LibDUK.compile_raw ctx, src, 0, options
    end

    def compile_string_filename!(src : String)
      err = compile_string_filename src
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
