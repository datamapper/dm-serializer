module DataMapper
  module Serializer
    module XML
      # The supported XML Serializers
      SERIALIZERS = {
        :libxml => 'LibXML',
        :nokogiri => 'Nokogiri',
        :rexml => 'REXML'
      }

      #
      # The current XML Serializer.
      #
      # @return [Module]
      #   The module within {DataMapper::Serialize::XML}.
      #
      # @since 1.1.0
      #
      def self.serializer
        @serializer
      end

      #
      # Sets the XML Serializer to use.
      #
      # @param [Symbol] name
      #   The name of the serializer to use. Must be either `:libxml`,
      #   `:nokogiri` or `:rexml`.
      #
      # @return [Module]
      #   The module within {DataMapper::Serialize::XML}.
      #
      # @since 1.1.0
      #
      def self.serializer=(name)
        serializer_const = SERIALIZERS[name]

        unless serializer_const
          raise(ArgumentError,"unsupported XML Serializer #{name}")
        end

        require "dm-serializer/xml/#{name}"
        @serializer = const_get(serializer_const)
      end

      [:nokogiri, :libxml, :rexml].each do |name|
        # attempt to load the first available XML Serializer
        begin
          self.serializer = name
          break
        rescue LoadError
        end
      end
    end
  end
end
