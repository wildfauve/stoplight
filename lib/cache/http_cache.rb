require "./lib/cache/http_cache_directives"
require "./lib/cache/http_cache_directives_value"

module AnyPort

  module HttpPort

    class HttpCache

      NOT_MODIFIED = 304

      HTTP_PIPELINE = [:hit, :check_for_modification, :make_request, :refresh_cache]

      CACHE = MiniCache::Store.new

      NOOP_RESULT = {value: nil, directives: HttpCacheDirectives.new.(headers: {}), headers: {} }

      def call(service_address:, request:)
        puts "HTTP Cache====> Call---for Service: #{service_address}"
        # Each step in the pipeline takes:
        # 1. A tuple containing the service_address and a block containing the request
        # 2. A Faraday result object
        # Each step determines, based on its input, whether to take an action
        # (such as performing the request, or augmenting headers)
        # it always returns the same a result hash containing resource cache directives value and additional headers hash
        HTTP_PIPELINE.inject({}) { |result, func| send(func, [service_address, request], result) }[:value]
      end

      def hit(input, result)
        puts "HTTP Cache====> In hit"
        hit = CACHE.get(input[0])
        if hit
          puts "HTTP Cache====> Cache Hit"
          Time.now <= hit[:directives].cache_valid_until ? hit : NOOP_RESULT
        else
          NOOP_RESULT
        end
      end

      def check_for_modification(input, result)
        puts "HTTP Cache====> in check_for_modification"
        if !result[:value] # there is nothing to check
          puts "HTTP Cache====> none to check"
          result
        else
          if revalidate(result[:directives])
            puts "HTTP Cache====> Revalidate with server"
            # Update the headers with the appropriate cache revalidation tags
            {value: result[:value], directives: result[:directives], headers: revalidate_headers(result[:directives])}
          end
        end
      end

      def make_request(input, result)
        puts "HTTP Cache====> in request"
        resp = input[1].call(result[:headers])
        if resp.status == NOT_MODIFIED   # Return the value from the cache
          puts "HTTP Cache====>  Not Modified"
          {value: result[:value], directives: HttpCacheDirectives.new.(headers: resp.headers), headers: {}}
        else
          puts "HTTP Cache====> Make Expense Call"
          {value: resp, directives: HttpCacheDirectives.new.(headers: resp.headers), headers: {}}
        end
      end

      def refresh_cache(input, result)
        puts "HTTP Cache====> in refresh_cache"
        if caching_enabled(result[:directives]) && result[:value].status != NOT_MODIFIED
          puts "HTTP Cache====> its cachable"
          CACHE.set(input[0], result)
        else
          puts "HTTP Cache=====> dont refresh cache"
        end
        result
      end


      def add(service_address:, value:, directives:)
        if caching_enabled(directives)
          CACHE.set(service_address, {value: value, directives: directives})
        end
      end

      # Takes the HttpCacheDirectivesValue and returns a hash of check server http headers
      def revalidate_headers(directives)
        [:if_modified_since, :if_none_match].inject({}) do | hrds, checker |
          hrd_prop = self.send(checker, directives)
          hrds[hrd_prop[0]] = hrd_prop[1] if hrd_prop
          hrds
        end
      end

      def revalidate(directives)
        directives.perform_modification_check || directives.revalidate
      end

      def caching_enabled(directives)
         directives.caching_enabled
      end

      def recheck_after_expiry(directives)
        directives.cache_valid_until < Time.now && directives.etag
      end

      def if_none_match(directives)
        recheck_after_expiry(directives) ? ["If-None-Match", directives.etag] : nil
      end

      def if_modified_since(directives)
        directives.revalidate ? ["If-Modified-Since", Time.now.httpdate] : nil
      end

    end

  end

end
