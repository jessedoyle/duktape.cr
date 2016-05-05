# logger.cr: internal logging mechanism
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

require "colorize"
require "logger"

module Duktape
  @@log : Logger?

  def self.logger
    @@log ||= make_logger
  end

  def self.headerize(text : String, color : Symbol)
    text.colorize(color).bold.underline
  end

  private def self.make_logger
    Logger.new(STDOUT).tap do |log|
      log.progname = "Duktape"
      log.level = Logger::Severity::INFO

      log.formatter = Logger::Formatter.new do |lev, _time, _name, msg, io|
        color = log_color lev
        unless msg.empty?
          text = msg.split ":"
          io << headerize text.shift, color
          if text.size > 0
            io << ":"
            io << text.join ":"
          end
        end
      end
    end
  end

  private def self.log_color(level : String)
    case level
    when "INFO"
      :light_cyan
    when "WARN"
      :white
    when "ERROR"
      :yellow
    when "FATAL"
      :red
    when "DEBUG"
      :magenta
    else
      :light_gray
    end
  end
end
