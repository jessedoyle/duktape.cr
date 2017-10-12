# time.cr: duktape time handling
#
# Copyright (c) 2017 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.
module Duktape
  module API
    module Time
      def get_now
        LibDUK.get_now ctx
      end

      def time_to_components(value : Float64)
        LibDUK.time_to_components ctx, value, out components
        components
      end

      def components_to_time(components : LibDUK::TimeComponents)
        LibDUK.components_to_time ctx, pointerof(components)
      end
    end
  end
end
