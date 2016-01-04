# logger.cr: internal logging mechanism
#
# Copyright (c) 2015 Jesse Doyle. All rights reserved.
#
# This is free software. Please see LICENSE for details.

require "colorize"
require "logger"

# FIXME: Crystal 0.10.0 core has a bug that closes the
# logger IO (STDOUT) at exit. This makes the spec
# suite crash. See this:
# https://github.com/manastech/crystal/issues/1982.
#
# This is a temporary monkey patch until a new version
# has been released.
class Logger(T)
  def initialize(@io : T)
    @level = Severity::INFO
    @formatter = DEFAULT_FORMATTER
    @progname = ""
    @channel = Channel(Message).new(100)
    @close_channel = Channel(Nil).new
    @closed = false
    @shutdown = false
    spawn write_messages
    at_exit { shutdown }
  end

  def close
    return if @closed
    @closed = true
    shutdown
  end

  private def write_messages
    loop do
      msg = Channel.receive_first(@channel, @close_channel)
      if msg.is_a?(Message)
        label = msg.severity == Severity::UNKNOWN ? "ANY" : msg.severity.to_s

        # We write to an intermediate String because the IO might be sync'ed so
        # we avoid some system calls. In the future we might want to add an IO#sync?
        # method to every IO so we can do this conditionally.
        @io << String.build do |str|
          formatter.call(label, msg.datetime, msg.progname.to_s, msg.message.to_s, str)
          str.puts
        end

        @io.flush
      else
        @io.close if @closed
        @close_channel.send(nil)
        break
      end
    end
  end

  private def shutdown
    return if @shutdown
    @shutdown = true
    @close_channel.send(nil)
    @close_channel.receive
  end
end

module Duktape
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
