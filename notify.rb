# require 'stoplight'
# require 'rest-client'
require 'pry'
# require 'redis'
# require 'diplomat'
require 'dry-container'
require 'dry-auto_inject'
# require 'mini_cache'
require 'dry-types'
# require 'ytry'

def set_up_container
  container = Dry::Container.new
  container.register("event_handler", -> { EventHandler.new } )
  container.register("subscriber", -> { Subscriber } )
  container.register("invoice_handler", -> { InvoiceHandler } )
  container
end

AutoInject = Dry::AutoInject(set_up_container)

# Dir["#{Dir.pwd}/lib/shared/*.rb"].each {|file| require file }
# Dir["#{Dir.pwd}/lib/resources/*.rb"].each {|file| require file }
# Dir["#{Dir.pwd}/lib/cache/*.rb"].each {|file| require file }
Dir["#{Dir.pwd}/lib/*.rb"].each {|file| require file }

#include AutoInject["event_handler"]

event = {kind: "invoice_payment", party: "/party/1", amount: "10.01"}

EventHandler.new.(event)

binding.pry


puts result
