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
    def eval
      flags = 2 |
        LibDUK::COMPILE_EVAL |
        LibDUK::COMPILE_SAFE |
        LibDUK::COMPILE_NOFILENAME

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
      validate_file! path

      flags = 3 |
        LibDUK::COMPILE_EVAL |
        LibDUK::COMPILE_SAFE

      LibDUK.push_string_file_raw ctx, path, LibDUK::STRING_PUSH_SAFE
      LibDUK.push_string ctx, path
      LibDUK.eval_raw ctx, nil, 0, flags
    end

    def eval_file!(path : String)
      raise_error eval_file(path)
    end

    def eval_file_noresult(path : String)
      validate_file! path

      flags = 3 |
        LibDUK::COMPILE_EVAL |
        LibDUK::COMPILE_SAFE |
        LibDUK::COMPILE_NORESULT

      LibDUK.push_string_file_raw ctx, path, LibDUK::STRING_PUSH_SAFE
      LibDUK.push_string ctx, path
      LibDUK.eval_raw ctx, nil, 0, flags
    end

    def eval_file_noresult!(path : String)
      raise_error eval_file_noresult(path)
    end

    def eval_lstring(src : String, length : Int)
      # We don't want to raise errors in non-bang
      # methods, so return with an error code.
      return LibDUK::ERR_API_ERROR if length < 0

      flags = 1 |
        LibDUK::COMPILE_EVAL |
        LibDUK::COMPILE_SAFE |
        LibDUK::COMPILE_NOSOURCE |
        LibDUK::COMPILE_NOFILENAME

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
      return LibDUK::ERR_API_ERROR if length < 0

      flags = 1 |
        LibDUK::COMPILE_EVAL |
        LibDUK::COMPILE_SAFE |
        LibDUK::COMPILE_NOSOURCE |
        LibDUK::COMPILE_NORESULT |
        LibDUK::COMPILE_NOFILENAME

      LibDUK.eval_raw ctx, src, length, flags
    end

    def eval_lstring_noresult!(src : String, length : Int)
      if length < 0
        raise ArgumentError.new "negative string length"
      end

      raise_error eval_lstring_noresult(src, length)
    end

    def eval_noresult
      flags = 2 |
        LibDUK::COMPILE_EVAL |
        LibDUK::COMPILE_SAFE |
        LibDUK::COMPILE_NORESULT |
        LibDUK::COMPILE_NOFILENAME

      LibDUK.eval_raw ctx, nil, 0, flags
    end

    def eval_noresult!
      raise_error eval_noresult
    end

    def eval_string(src : String)
      flags = 1 |
        LibDUK::COMPILE_EVAL |
        LibDUK::COMPILE_NOSOURCE |
        LibDUK::COMPILE_STRLEN |
        LibDUK::COMPILE_SAFE |
        LibDUK::COMPILE_NOFILENAME

      LibDUK.eval_raw ctx, src, 0, flags
    end

    def eval_string!(src : String)
      raise_error eval_string(src)
    end

    def eval_string_noresult(src : String)
      flags = 1 |
        LibDUK::COMPILE_EVAL |
        LibDUK::COMPILE_SAFE |
        LibDUK::COMPILE_NOSOURCE |
        LibDUK::COMPILE_STRLEN |
        LibDUK::COMPILE_NORESULT |
        LibDUK::COMPILE_NOFILENAME

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
      rescue ex : Errno
        msg = String.new LibC.strerror(ex.errno)
        raise Duktape::FileError.new "#{path} : #{msg}"
      ensure
        file.close if file
      end
    end
  end
end
