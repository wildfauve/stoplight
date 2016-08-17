class EventHandler

  include AutoInject["event_handlers.event_handler_factory", "subscriber"]

  def call(event)
    event_handler_factory.(event[:kind]).(event, subscriber.new.find_by_party(event))
  end

end
