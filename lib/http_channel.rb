module AnyPort

  module HttpPort

    class HttpChannel

      attr_accessor :status, :response_body, :http_status

      include HttpPort::AutoInject["service_discovery", "http_response_value", "http_cache_directives", "http_cache"]

      class RemoteServiceError < PortException ; end
      class MediaContentError < PortException ; end


      SUPPORTED_MIME_TYPE_PARSERS = {
        "text/html" => :html_parser,
        "application/json" => :json_parser
      }

      def resource=(resource)
        @resource = resource
      end

      def environment=(environment)
        @environment = environment
      end

      def service=(service)
        @service = service
      end

      def method=(method)
        @method = method
      end

      def return_cache_directives
        @cache_directives = true
      end

      def try_cache
        @try_cache = true
      end


      def call
        port_binding = service_discovery.new.find(service: @service, environment: @environment) + @resource
        to_port(service_address: port_binding, method: @method)
      end

      private

      # HTTP port
      # service_address: a URL
      def to_port(service_address: nil, method: nil, body: nil)
        begin
          self.send(method, service_address, body)
        rescue Faraday::Error => e
          raise self.class::RemoteServiceError.new(msg: e.cause)
        end
      end


      def get(service_address, body)
        service_call = ->(headers={}) { connection(service_address, headers).send(:get) }
        resp = if @try_cache
          get_through_cache(address: service_address, otherwise: service_call)
        else
          service_call.call
        end
        respond(resp)
      end

      def get_through_cache(address:, otherwise:)
        http_cache.(service_address: address, request: otherwise)
      end

      def post(service_address, body)
        connection = Faraday.new(service_address)
        resp = connection.send(:post) do |req|
          req.headers['Content-Type'] = 'application/json'
          req.body = JSON.generate(body)
        end
        response_body = JSON.parse(resp.body) rescue {}
        response_value.new(body: response_body, status: evalulate_status(resp.status))
      end

      def respond(resp)
        http_response_value.new(
                                  body: parse_body(resp.headers[:content_type], resp.body),
                                  status: evalulate_status(resp.status)
                                )
      end

      def connection(address, headers={})
        hrds = {"Content-Type" => "application/json"}.merge!(headers)
        connection = Faraday.new(address)
        connection.headers.merge!(hrds)
        puts "====> HTTP Channel:  Added Headers: Input: #{hrds}   Connection Headers: #{connection.headers}"
        connection
      end

      def evalulate_status(http_status)
        if http_status < 300
          :ok
        else
          :not_ok
        end
      end

      def parse_body(content_type, body)
        content_type ? mime = content_type.split(";").first : mime = "application/json"
        if SUPPORTED_MIME_TYPE_PARSERS.keys.include? mime
          self.send(SUPPORTED_MIME_TYPE_PARSERS[mime], body)
        else
          raise self.class::MediaContentError.new(retryable: false)
        end
      end

      def html_parser(body)
        body
      end

      def json_parser(body)
        JSON.parse(body)
      end

    end

  end

end
