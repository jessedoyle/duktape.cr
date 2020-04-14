def last_stack_type(ctx)
  LibDUK.get_type(ctx.raw, -1)
end
