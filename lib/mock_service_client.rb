class MockServiceClient
  include AnyPort::Circuit
  include AnyPort::HttpPort
  include Ytry

  SERVICE = :hamsters

  def get_by_resource(qos: {}, resource: )
  end


  def get_all_hamsters(qos: {})
    # begin
      HamstersCollection.new(MockServiceAdapter.new.retrieve(service: SERVICE, resource: "/hamsters", qos: {}))
    # rescue AnyPort::PortException => e
    # end
  end


end
