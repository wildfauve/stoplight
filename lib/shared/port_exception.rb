module AnyPort

  class PortException < StandardError

    attr_reader :error_code, :retryable

    def initialize(msg: "", code: nil, retryable: true)
      self.error_code = code
      @retryable = retryable
      super(msg)
    end

    def error_code=(code)
      if code
        @error_code = code
      else
        @error_code = "urn:port:error:#{self.class.to_s.downcase.gsub("::",":")}"
      end
    end

  end

end
