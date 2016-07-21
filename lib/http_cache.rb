module AnyPort

  module HttpPort

    class HttpCache

      NOT_MODIFIED = 304

      CACHE = MiniCache::Store.new

      def hit(service_address:)
        hit = CACHE.get(service_address)
        if hit
          Time.now <= hit[:directives].cache_valid_until ? hit : nil
        else
          nil
        end
      end

      def call(service_address:, request:)
        cached_resp = hit(service_address: service_address)
        if !cached_resp
          resp = make_request(service_address, request, {})
        else
          puts "====> From Cache"
          if revalidate(cached_resp[:directives])
            puts "====> Revalidate with server"
            resp = make_request(service_address, request, revalidate_headers(cached_resp[:directives]))
            resp = cached_resp[:value] if !resp
          end
        end
        resp
      end

      def make_request(service_address, request, headers)
        resp = request.call(headers)
        if resp.status == NOT_MODIFIED
          puts "====> Not Modified"
          nil
        else
          add(service_address: service_address, value: resp, directives: HttpCacheDirectives.new.(headers: resp.headers) )
          resp
        end
      end


      def add(service_address:, value:, directives:)
        if caching_enabled(directives)
          CACHE.set(service_address, {value: value, directives: directives})
        end
        # binding.pry
      end

      def revalidate_headers(directives)
        binding.pry
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
