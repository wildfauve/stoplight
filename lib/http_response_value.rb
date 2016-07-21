class HttpResponseValue

  attr_reader :status, :body, :caching

  def initialize(status:, body:, from_cache: false)
    @status = status
    @body = body
  end


end
