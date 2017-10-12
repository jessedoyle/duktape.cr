# base.cr: Duktape builtin function abstract class.
# Copyright (c) 2017 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module BuiltIn
    abstract struct Base
      getter ctx
      @ctx : Duktape::Context | Duktape::Sandbox

      def initialize(@ctx : Duktape::Context | Duktape::Sandbox)
      end

      abstract def import!
    end
  end
end

require "./alert"
require "./console"
require "./print"
