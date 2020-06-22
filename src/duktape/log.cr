# log.cr: crystal >= 0.34 log implementation
#
# Copyright (c) 2020 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

require "log"
require "json"

Log.setup_from_env(
  default_sources: ENV.fetch("LOG_SOURCES", "duktape.*"),
  backend: Log::IOBackend.new.tap do |backend|
    backend.formatter = Duktape::Log.formatter
  end
)

module Duktape
  module Log
    Base    = ::Log.for("duktape")
    Alert   = ::Log.for("duktape.alert")
    Console = ::Log.for("duktape.console")

    @@formatter : ::Log::Formatter?

    def self.formatter
      @@formatter ||= ::Log::Formatter.new do |entry, io|
        timestamp = Time::Format::ISO_8601_DATE_TIME.format(time: entry.timestamp)

        if entry.exception
          exception = entry.exception.class.name
        else
          exception = nil
        end

        io << {
          exception: exception,
          message:   entry.message,
          severity:  entry.severity.label,
          source:    entry.source,
          timestamp: timestamp,
        }.to_json
      end
    end
  end
end
