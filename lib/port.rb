module AnyPort

  class Port

    # Return a Port based on the QOS....well, sort of....
    def port_for_message_exchange_pattern(qos)
      AnyPort::HttpPort2.new
    end

  end

end
