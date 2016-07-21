module AnyPort

  class CircuitBreaker

    class CircuitOpen < PortException ; end
    class CircuitUnavailable < PortException ; end

    MAX_RETRIES = 3

    def initialize()
      # redis = Redis.new
      # datastore = Stoplight::DataStore::Redis.new(redis)
      # Stoplight::Light.default_data_store = datastore
    end

    def service_name=(name)
      @service_name = name
    end

    def call(&block)
      circuit = Stoplight(@service_name) {block.call}.with_threshold(MAX_RETRIES).with_cool_off_time(10)
      result = nil
      begin
        "Begin==> #{circuit.color}"
        result = circuit.run
      rescue ServiceDiscovery::ServiceDiscoveryNotAvailable => e
        raise self.class::CircuitUnavailable.new(msg: e.cause)
      rescue PortException => e
        puts "Exception Circuit Color==> #{circuit.color} #{e.inspect}"
        raise e unless e.retryable
        if circuit.color == Stoplight::Color::RED
          raise self.class::CircuitOpen.new(msg: e.cause)
        else
          retry
        end
      end
      result
    end

    def get_info(light)
      puts Stoplight::Light.default_data_store.get_all(light)
    end

    def rundownred(light)
      until light.color == "green"
        puts light.color
      end
    end

  end

end
