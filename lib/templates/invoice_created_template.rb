class InvoiceCreatedTemplate < BaseTemplate

  attr_reader :event, :subscriber

  def initialize(event, subscriber)
    @event = event
    @subscriber = subscriber
  end

  def name
    "Invoice Created"
  end

  def subject
    "Flick Invoice Payment About to Happen"
  end

  def message
    {
      text: "Flick Invoice Payment",
      subject: "Flick Invoice Payment",
    }
  end

  def template_values
    {
      global_merge_vars: [
        map_values
      ]
    }
  end

  def map_values
    mappings.inject({}) {|vals, (val_name, val_constructor)| vals[val_name] = val_constructor[:from].(); vals}
  end

  def mappings
    {
      subject: { from: -> { subject } },
      name: { from: -> { subscriber.name } },
      amount: { from: -> { event.amount } },
      invoice_date: {from: -> { event.invoice_date } }
    }
  end

  # general_variables:
  #   week_bill
  #   fname
  #   bill_to_pay
  #   update_profile
  #   unsub
  #   invoice_has_estimates
  #
  #
  # conditionals:
  #   first_bill
  #   multi_bills




end
