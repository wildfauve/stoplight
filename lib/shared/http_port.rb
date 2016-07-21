module AnyPort

  module HttpPort

    def self.included(base)
      base.extend(ClassMethods)
      base.include(AutoInject["http_channel"])
    end

    def get(&block)
      port = http_channel
      yield port
      port.method = :get
      port
    end

    def post(&block)
      port = http_channel
      yield port
      port.method = :post
      port
    end

    module ClassMethods

      def self.set_up_container
        port_container = Dry::Container.new
        port_container.register("http_channel", -> {HttpChannel.new} )
        port_container.register("service_discovery", -> {AnyPort::ServiceDiscovery} )
        port_container.register("http_response_value", -> {HttpResponseValue} )
        port_container.register("http_cache_directives", -> {HttpCacheDirectives} )
        port_container.register("http_cache", -> {HttpCache.new} )
        port_container
      end

      AnyPort::HttpPort::AutoInject = Dry::AutoInject(set_up_container)

    end

  end

end
