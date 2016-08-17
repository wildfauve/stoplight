require 'pry'
require 'dry-container'
require 'dry-auto_inject'
require 'dry-types'
require 'dry-validation'
require 'dry-monads'


def set_up_container
  container = Dry::Container.new
  container.register("subscriber", -> { Subscriber } )
  container.namespace("event_handlers") do
    register("event_handler", -> { EventHandler.new } )
    register("invoice_created_handler", -> { InvoiceCreatedHandler.new } )
    register("event_handler_factory", -> { EventHandlerFactory.new } )
  end
  container.namespace("values") do
    register("invoice_created_value", -> { InvoiceCreatedValue } )
    register("subscriber_value", -> { SubscriberValue } )
  end
  container.namespace("channel_handlers") do
    register("channel_handler_factory", -> { ChannelHandlerFactory } )
    register("email_channel_handler", -> { EmailChannelHandler.new} )
    register("email_mapper", -> { MandrillMapper.new} )
  end
  container.namespace("templates") do
    register("template_factory", -> { TemplateFactory.new } )
    register("invoice_created_template", -> { InvoiceCreatedTemplate } )
  end
  container
end

Container = set_up_container
AutoInject = Dry::AutoInject(Container)

M = Dry::Monads

# Dir["#{Dir.pwd}/lib/shared/*.rb"].each {|file| require file }
# Dir["#{Dir.pwd}/lib/resources/*.rb"].each {|file| require file }
# Dir["#{Dir.pwd}/lib/cache/*.rb"].each {|file| require file }
Dir["#{Dir.pwd}/lib/**/*.rb"].each {|file| require file }

event = {kind: "invoice.created", party: "/party/1", amount: "10.01", invoice_date: Date.today.iso8601}

Container["event_handlers.event_handler"].(event)
