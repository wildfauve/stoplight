class InvoiceCreatedHandler

  include AutoInject["channel_handlers.channel_handler_factory", "values.invoice_created_value", "templates.template_factory"]

  INVOICE_SUBJECT = :invoice

  def call(event, subscriber)
    chans = channels(subscriber)
    if chans.some?
      channel_handler_factory.new.(chans.value)
                              .map {|handler| handler.(event: event_value(event),
                                                      subscriber: subscriber,
                                                      template: template_factory.(event_value(event)).new(event_value(event), subscriber))
                                  }
    end
  end

  def channels(sub)
    s  = -> (x) { M.Maybe(x[INVOICE_SUBJECT]) }
    M.Maybe(sub[:subjects]).bind(s)  # This really protects against nil subjects
  end

  def event_value(event)
    @event_value ||= invoice_created_value.new(
                            kind: event[:kind],
                            party_url: event[:party_url],
                            amount: event[:amount],
                            invoice_date: event[:invoice_date]
                          )
  end

  def validate
    base_schema = Dry::Validation.Form do
      required(:kind).filled(:str?)
      required(:party).filled(:str?)
      required(:amount).filled(:float?)
      required(:invoice_date).filled(:str?)
    end

    parse = base_schema.(event)
    raise if parse.failure?
    parse.output
  end


end
