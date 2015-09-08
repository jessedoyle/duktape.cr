# debug.cr: various duktape debug operations
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Debug
    def stack
      push_context_dump
      require_string(-1).tap do
        pop
      end
    end

    def dump!
      Duktape.logger.info "STACK: #{stack}"
    end
  end
end
