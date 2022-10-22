# version.cr: duktape protocol and wrapper version
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  def self.version
    VERSION::STRING
  end

  def self.api_version
    VERSION::API
  end

  module VERSION
    MAJOR = 1
    MINOR = 0
    TINY  = 1
    PRE   = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join "."

    # Internal Duktape Version
    API = [2, 5, 0].join "."
  end
end
