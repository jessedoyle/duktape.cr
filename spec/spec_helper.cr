ENV["CRYSTAL_PATH"] = "#{__DIR__}/../src"
ENV["VERIFY"] = "1"

require "spec"
require "../src/lib_duktape"
require "../src/duktape"
require "../src/duktape/**"
require "./support/**"

# Disable logging
Duktape.logger.level = Logger::Severity::UNKNOWN

JS_SOURCE_PATH = "#{__DIR__}/javascripts"
