module AnyPort

  class ServiceDiscovery

    class ServiceDiscoveryNotAvailable < PortException ; end

    def find(service:, environment:)
      begin
        service = Diplomat::Service.get(service.to_s)
        raise self.class::ServiceDiscoveryNotAvailable.new(msg: e.cause, retryable: false) if !service.respond_to? :Address
        "http://#{service.ServiceAddress}:#{service.ServicePort}"
      rescue Diplomat::PathNotFound => e
        raise ServiceDiscoveryNotAvailable.new(msg: e.cause, retryable: false)
      end

    end

  end

end
