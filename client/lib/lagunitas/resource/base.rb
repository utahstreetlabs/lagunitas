require 'ladon/resource/base'

module Lagunitas
  module Resource
    # Just here so that we can set class attributes for all Lagunitas resources.
    class Base < Ladon::Resource::Base
      self.base_url = 'http://localhost:4000'

      # Force all subclasses to use the base class's base url.
      def self.base_url
        self == Base ? super : Base.base_url
      end

      # @option options [Integer] :page
      # @option options [Integer] :per
      # @option options [Array] :attr if present, narrows the attributes of the returned entities to just this set
      # @return [Ladon::PaginatableArray] ({total: 0, results: []})
      # @see Ladon::Resource::Base#fire_get
      def self.fire_paged_query(url, options = {})
        defaults = {default_data: {total: 0, results: []}, params_map: {attr: :attr}, pre_paged: true}
        options = options.reverse_merge(defaults)
        fire_get(url, options)
      end

      def self.fire_count_query(url)
        data = fire_get(url, default_data: {count: 0})
        if data.respond_to?(:[])
          data[:count]
        else
          logger.warn("Malformed count query result: #{data.inspect}")
          0
        end
      end
    end
  end
end
