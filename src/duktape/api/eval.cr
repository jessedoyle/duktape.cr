# eval.cr: duktape api evaluation operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  # NOTE: These methods are all equivalent to the Duktape
  # `peval_xxx` functions because we wish to safely return
  # from errors.
  module API::Eval
    include Support::File

    def eval
      flags = LibDUK::Compile.new(1_u32) |
              LibDUK::Compile::Eval |
              LibDUK::Compile::Safe |
              LibDUK::Compile::NoFilename

      LibDUK.eval_raw ctx, nil, 0, flags
    end

    def eval(str : String)
      eval_string str
    end

    def eval!
      raise_error eval
    end

    def eval!(str : String)
      eval_string! str
    end

    def eval_file(path : String)
      eval_string read_file(path)
    end

    def eval_file!(path : String)
      eval_string! read_file(path)
    end

    def eval_file_noresult(path : String)
      eval_string_noresult read_file(path)
    end

    def eval_file_noresult!(path : String)
      eval_string_noresult! read_file(path)
    end

    def eval_lstring(src : String, length : Int)
      # We don't want to raise errors in non-bang
      # methods, so return with an error code.
      return LibDUK::Err::Error if length < 0

      flags = LibDUK::Compile.new(0_u32) |
              LibDUK::Compile::Eval |
              LibDUK::Compile::Safe |
              LibDUK::Compile::NoSource |
              LibDUK::Compile::NoFilename

      LibDUK.eval_raw ctx, src, length, flags
    end

    def eval_lstring!(src : String, length : Int)
      if length < 0
        raise ArgumentError.new "negative string length"
      end

      raise_error eval_lstring(src, length)
    end

    def eval_lstring_noresult(src : String, length : Int)
      # We don't want to raise errors in non-bang
      # methods, so return with an error code.
      return LibDUK::Err::Error if length < 0

      flags = LibDUK::Compile.new(0_u32) |
              LibDUK::Compile::Eval |
              LibDUK::Compile::Safe |
              LibDUK::Compile::NoSource |
              LibDUK::Compile::NoResult |
              LibDUK::Compile::NoFilename

      LibDUK.eval_raw ctx, src, length, flags
    end

    def eval_lstring_noresult!(src : String, length : Int)
      if length < 0
        raise ArgumentError.new "negative string length"
      end

      raise_error eval_lstring_noresult(src, length)
    end

    def eval_noresult
      flags = LibDUK::Compile.new(1_u32) |
              LibDUK::Compile::Eval |
              LibDUK::Compile::Safe |
              LibDUK::Compile::NoResult |
              LibDUK::Compile::NoFilename

      LibDUK.eval_raw ctx, nil, 0, flags
    end

    def eval_noresult!
      raise_error eval_noresult
    end

    def eval_string(src : String)
      flags = LibDUK::Compile.new(0_u32) |
              LibDUK::Compile::Eval |
              LibDUK::Compile::NoSource |
              LibDUK::Compile::StrLen |
              LibDUK::Compile::Safe |
              LibDUK::Compile::NoFilename

      LibDUK.eval_raw ctx, src, 0, flags
    end

    def eval_string!(src : String)
      raise_error eval_string(src)
    end

    def eval_string_noresult(src : String)
      flags = LibDUK::Compile.new(0_u32) |
              LibDUK::Compile::Eval |
              LibDUK::Compile::Safe |
              LibDUK::Compile::NoSource |
              LibDUK::Compile::StrLen |
              LibDUK::Compile::NoResult |
              LibDUK::Compile::NoFilename

      LibDUK.eval_raw ctx, src, 0, flags
    end

    def eval_string_noresult!(src : String)
      raise_error eval_string_noresult(src)
    end

    # Duktape throws ugly internal errors when it
    # fails any file operations. Let's just perform
    # some sanity checks in Crystal to determine
    # more information about potential errors.
    private def validate_file!(path : String)
      unless File.exists? path
        raise Duktape::FileError.new "invalid file: #{path}"
      end

      # Can we read the file?
      begin
        file = File.open path, "r"
      rescue ex : File::Error
        msg = String.new LibC.strerror(ex.errno)
        raise Duktape::FileError.new "#{path} : #{msg}"
      ensure
        file.close if file
      end
    end
  end
end
