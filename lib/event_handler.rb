class EventHandler

  include AutoInject["invoice_handler", "subscriber"]

  def call(event)
    invoice_handler.new.(event, subscriber.find_by_party(event))
  end

end
