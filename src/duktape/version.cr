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
    MAJOR = 0
    MINOR = 6
    TINY  = 0
    PRE   = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join "."

    # Internal Duktape Version
    API = [1, 3, 0].join "."
  end
end
