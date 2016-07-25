module AnyPort

  module HttpPort

    class HttpCache

      NOT_MODIFIED = 304

      HTTP_PIPELINE = [:hit, :check_for_modification, :make_request, :refresh_cache]

      CACHE = MiniCache::Store.new

      def call(service_address:, request:)
        puts "HTTP Cache====> Call---for Service: #{service_address}"
        # Each step in the pipeline takes:
        # 1. A tuple containing the service_address and a block containing the request
        # 2. A Faraday result object
        # Each step determines, based on its input, whether to take an action (such as performing the request, or augmenting headers)
        HTTP_PIPELINE.inject({}) { |result, func| send(func, [service_address, request], result) }[:value]
      end

      def hit(input, result)
        puts "HTTP Cache====> In hit"
        hit = CACHE.get(input[0])
        if hit
          puts "HTTP Cache====> Cache Hit"
          Time.now <= hit[:directives].cache_valid_until ? hit : {value: nil, directives: {}}
        else
          {value: nil, directives: {}}
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
            {value: result[:value], directives: revalidate_headers(result[:directives])}
          end
        end
      end

      def make_request(input, result, headers=nil)
        puts "HTTP Cache====> in request"
        resp = input[1].call(result[:directives])
        if resp.status == NOT_MODIFIED
          # TODO: check what headers are returned...use should not overwrite the existing cache headers.
          puts "HTTP Cache====>  Not Modified"
          binding.pry
          {value: resp, directives: HttpCacheDirectives.new.(headers: resp.headers)}
        else
          puts "HTTP Cache====> Make Expense Call"
          {value: resp, directives: HttpCacheDirectives.new.(headers: resp.headers)}
        end
      end

      def refresh_cache(input, result)
        puts "HTTP Cache====> in refresh_cache"
        if caching_enabled(result[:directives])
          puts "HTTP Cache====> its cachable"
          # TODO: check the if-not-modified path
          CACHE.set(input[0], result)
        end
        result
      end


      def add(service_address:, value:, directives:)
        if caching_enabled(directives)
          CACHE.set(service_address, {value: value, directives: directives})
        end
      end

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
