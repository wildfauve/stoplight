require 'stoplight'
require 'rest-client'
require 'pry'
require 'redis'
require 'diplomat'
require 'dry-container'
require 'dry-auto_inject'
require 'mini_cache'
require 'dry-types'

Dir["#{Dir.pwd}/lib/shared/*.rb"].each {|file| require file }

Dir["#{Dir.pwd}/lib/*.rb"].each {|file| require file }


class MockClient
  include AnyPort::HttpPort

  def call(service, resource, environment)
    result = get do |http_port|
      http_port.service = service
      http_port.resource = resource
      http_port.environment = environment
      http_port.return_cache_directives
      http_port.try_cache
    end.()
  end
end

class MockServiceAdapter
  include AnyPort::Circuit

  def perform
    service = :hamsters
    resource = "/hamsters"
    begin
      result = with_circuit do |circuit|
        circuit.service_name = resource
      end.call {MockClient.new.call(service, resource, :development)}
    rescue AnyPort::CircuitBreaker::CircuitOpen => e
      puts "===>CircuitBreaker Open Exception"
    rescue AnyPort::PortException => e
      puts "===>General Port Exception, #{e}"
    end
    result
  end

end

class MockServiceAdapterWithoutCircuit

  def perform
    service = :hamsters
    resource = "/hamsters"
    begin
      MockClient.new.call(service, resource, :development)
    rescue AnyPort::PortException => e
      binding.pry
    end
  end
end


result = MockServiceAdapter.new.perform
puts result.body
result = MockServiceAdapter.new.perform
binding.pry
# MockServiceAdapterWithoutCircuit.new.perform

puts result
