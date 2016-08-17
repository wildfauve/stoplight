class ChannelHandlerFactory

  def call(channels)
    channels.map {|channel| Container.resolve(channel_slug(channel))}
  end

  def channel_slug(channel)
    "channel_handlers.#{channel}_channel_handler"
  end



end
