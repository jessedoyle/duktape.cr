# file.cr: file handling utilities
#
# Copyright (c) 2017 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module Support::File
    private def read_file(path : String)
      ::File.read path
    rescue ex : ::File::Error
      raise FileError.new "invalid file: #{ex.message}"
    end
  end
end
