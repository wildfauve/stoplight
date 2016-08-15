class MockServiceAdapter
  include AnyPort::Circuit
  include Ytry

  ENVIRONMENT = :development

  class RequestFailure < AnyPort::PortException ; end

  # given a service and resource, return the data associated with it.
  def retrieve(service:, resource:, qos: {} )
    port = AnyPort::Port.new.port_for_message_exchange_pattern(qos)
    # result = Try {
    result =  with_circuit do |circuit|
        circuit.service_name = resource
      end.call { get(port, service, resource, ENVIRONMENT) }
    # }

    # result.get_or_else {raise self.class::RequestFailure}
    # begin
    #   result = with_circuit do |circuit|
    #     circuit.service_name = resource
    #   end.call {MockClient.new.call(service, resource, :development)}
    # rescue AnyPort::CircuitBreaker::CircuitOpen => e
    #   puts "===>CircuitBreaker Open Exception"
    # rescue AnyPort::PortException => e
    #   puts "===>General Port Exception, #{e}"
    # end
  end

  def get(port, service, resource, environment)
    port.get do |p|
      p.service = service
      p.resource = resource
      p.environment = environment
      p.return_cache_directives
      p.try_cache
    end.()
  end


end
