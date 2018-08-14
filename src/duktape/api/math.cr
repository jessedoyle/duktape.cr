# heap.cr: duktape arithmetic operations
#
# Copyright (c) 2018 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module API::Math
    def random
      LibDUK.random ctx
    end
  end
end
