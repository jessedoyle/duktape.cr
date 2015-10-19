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
      flags = LibDUK::COMPILE_EVAL |
                LibDUK::COMPILE_SAFE

      LibDUK.push_string ctx, __FILE__
      LibDUK.eval_raw ctx, nil, 0, flags
    end

    def eval(str : String)
      eval_string str
    end

    def eval!
      err = eval
      raise_error err
    end

    def eval!(str : String)
      eval_string! str
    end

    def eval_file(path : String)
      validate_file! path

      flags = LibDUK::COMPILE_EVAL |
                LibDUK::COMPILE_SAFE

      LibDUK.push_string_file_raw ctx, path, 0_u32
      LibDUK.push_string ctx, path
      LibDUK.eval_raw ctx, nil, 0, flags
    end

    def eval_file!(path : String)
      err = eval_file path
      raise_error err
    end

    def eval_file_noresult(path : String)
      validate_file! path

      flags = LibDUK::COMPILE_EVAL |
                LibDUK::COMPILE_SAFE |
                LibDUK::COMPILE_NORESULT

      LibDUK.push_string_file_raw ctx, path, 0_u32
      LibDUK.push_string ctx, path
      LibDUK.eval_raw ctx, nil, 0, flags
    end

    def eval_file_noresult!(path : String)
      err = eval_file_noresult path
      raise_error err
    end

    def eval_lstring(src : String, length : Int)
      # We don't want to raise errors in non-bang
      # methods, so return with an error code.
      return LibDUK::ERR_API_ERROR if length < 0

      flags = LibDUK::COMPILE_EVAL |
                LibDUK::COMPILE_SAFE |
                LibDUK::COMPILE_NOSOURCE

      LibDUK.push_string ctx, __FILE__
      LibDUK.eval_raw ctx, src, length, flags
    end

    def eval_lstring!(src : String, length : Int)
      if length < 0
        raise Error.new "negative string length"
      end

      err = eval_lstring src, length
      raise_error err
    end

    def eval_lstring_noresult(src : String, length : Int)
      # We don't want to raise errors in non-bang
      # methods, so return with an error code.
      return LibDUK::ERR_API_ERROR if length < 0

      flags = LibDUK::COMPILE_EVAL |
                LibDUK::COMPILE_SAFE |
                LibDUK::COMPILE_NOSOURCE |
                LibDUK::COMPILE_NORESULT

      LibDUK.push_string ctx, __FILE__
      LibDUK.eval_raw ctx, src, length, flags
    end

    def eval_lstring_noresult!(src : String, length : Int)
      if length < 0
        raise Error.new "negative string length"
      end

      err = eval_lstring_noresult src, length
      raise_error err
    end

    def eval_noresult
      flags = LibDUK::COMPILE_EVAL |
                LibDUK::COMPILE_SAFE |
                LibDUK::COMPILE_NORESULT

      LibDUK.push_string ctx, __FILE__
      LibDUK.eval_raw ctx, nil, 0, flags
    end

    def eval_noresult!
      err = eval_noresult
      raise_error err
    end

    def eval_string(src : String)
      flags = LibDUK::COMPILE_EVAL |
                LibDUK::COMPILE_NOSOURCE |
                LibDUK::COMPILE_STRLEN |
                LibDUK::COMPILE_SAFE

      LibDUK.push_string ctx, __FILE__
      LibDUK.eval_raw ctx, src, 0, flags
    end

    def eval_string!(src : String)
      err = eval_string src
      raise_error err
    end

    def eval_string_noresult(src : String)
      flags = LibDUK::COMPILE_EVAL |
                LibDUK::COMPILE_SAFE |
                LibDUK::COMPILE_NOSOURCE |
                LibDUK::COMPILE_STRLEN |
                LibDUK::COMPILE_NORESULT

      LibDUK.push_string ctx, __FILE__
      LibDUK.eval_raw ctx, src, 0, flags
    end

    def eval_string_noresult!(src : String)
      err = eval_string_noresult src
      raise_error err
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

    private def raise_error(err) # :nodoc:
      # We want to return the code (0) if no
      # error is raised
      err.tap do |error|
        unless error == 0
          code = LibDUK.get_error_code ctx, -1
          if code == 0
            raise StackError.new "error object missing"
          else
            raise Duktape::Error.new safe_to_string -1
          end
        end
      end
    end
  end
end
