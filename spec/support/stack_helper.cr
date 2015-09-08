def last_stack_type(ctx)
  LibDUK.get_type(ctx.raw, -1)
end

def log_debug
  Duktape.logger.level = Logger::Severity::DEBUG
  yield
  Duktape.logger.level = Logger::Severity::UNKNOWN
end

def print_stack!(ctx)
  log_debug do
    ctx.dump!
  end
end
