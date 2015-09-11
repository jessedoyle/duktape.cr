# time.cr: miscellaneous time creation/conversion tools
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

module Duktape
  module Support::Time
    def current_time_nano
      LibC.gettimeofday(out time, nil).tap do |rc|
        unless rc == 0
          raise Error.new \
          "can't get system time"
        end
      end
      time
    end

    def milli_to_secs(milli : Int32 | Int64)
      LibC::TimeT.cast milli.to_i64/1000
    end

    def milli_to_nano(milli : Int32 | Int64)
      milli = milli.to_i64
      secs  = milli/1000
      LibC::UsecT.cast((milli*1000) - (secs*1_000_000))
    end
  end
end
