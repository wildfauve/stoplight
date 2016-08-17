class EventHandlerFactory

  def call(event_kind)
    Container.resolve(event_kind_slug(event_kind))
  end

  def event_kind_slug(event_kind)
    "event_handlers.#{event_kind.gsub(".", "_")}_handler"
  end


end
