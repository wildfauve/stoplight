module AnyPort

  module HttpPort

    class HttpCacheDirectives

      include Ytry

      attr_reader :caching_enabled, :perform_modification_check, :cache_valid_until, :revalidate

    #   "etag"=>"\"70d959ef58229c4a7e402201a131d430\"",
    #   "cache-control"=>"max-age=0, private, must-revalidate",
    #   age

      def call(headers:)
        @headers = headers
        puts "CACHE Directives: cache-control: #{@headers["cache-control"]}"
        puts "CACHE Directives: etag: #{@headers["etag"]}"
        puts "CACHE Directives: expires: #{@headers["expires"]}"

        analyse_cache_directives
        HttpCacheDirectivesValue.new( caching_enabled: caching_enabled,
                                      perform_modification_check: perform_modification_check,
                                      cache_valid_until: cache_valid_until,
                                      revalidate: revalidate,
                                      etag: etag)
      end

      def etag
        @headers["etag"]
      end

      def max_age
        age = @headers["max_age"] || max_age_from_control
        age ? age.to_i : 0
      end


      private

      def analyse_cache_directives
        @caching_enabled = true
        @perform_modification_check = false
        @revalidate =  must_revalidate_present?
        @caching_enabled = false if no_store_present?
        if no_cache_present? && etag_present?
          @perform_modification_check = true
        elsif no_cache_present? && !etag_present
          @caching_enabled = false
        end
        caching_expired if @caching_enabled
      end

      def caching_expired
        @cache_valid_until = Time.now + max_age.to_i
      end

      def max_age_from_control
        cache_control.select {|directive| directive =~ /^max-age=/}.map {|tokens| tokens.split("=")}.flatten.last
      end

      def etag_present?
        cache_control.include? "etag"
      end

      def cache_control
        # @headers["cache-control"] ? @control ||= @headers["cache-control"].gsub(" ", "").split(",") : @control = []
        @control ||= Try { @headers[:cache_control].gsub(" ", "")  }.get_or_else {""}.split(",")
      end

      def no_cache_present?
        cache_control.include? "no_cache"
      end

      def no_store_present?
        cache_control.include? "no_store"
      end

      def must_revalidate_present?
        cache_control.include? "must-revalidate"
      end


    end

  end

end
