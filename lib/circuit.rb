module AnyPort

  module Circuit
    def self.included(base)
      base.extend(ClassMethods)
    end

    def with_circuit(&block)
      circuit = CircuitBreaker.new
      yield circuit
      circuit
    end

    module ClassMethods
    end

  end

end
