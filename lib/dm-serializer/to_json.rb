require 'dm-serializer/common'

require 'json'

module DataMapper
  module Serialize
    #
    # Converts the resource into a hash of properties.
    #
    # @param [Hash] options
    #   Additional options.
    #
    # @return [Hash{String => String}]
    #   The hash of resources properties.
    #
    # @since 1.0.1
    #
    def as_json(options = {})
      result = {}

      properties_to_serialize(options).each do |property|
        property_name = property.name
        result[property_name] = __send__(property_name)
      end

      # add methods
      Array(options[:methods]).each do |method|
        next unless respond_to?(method)
        result[method] = __send__(method)
      end

      # Note: if you want to include a whole other model via relation, use :methods
      # comments.to_json(:relationships=>{:user=>{:include=>[:first_name],:methods=>[:age]}})
      # add relationships
      # TODO: This needs tests and also needs to be ported to #to_xml and #to_yaml
      (options[:relationships] || {}).each do |relationship_name, opts|
        next unless respond_to?(relationship_name)
        result[relationship_name] = __send__(relationship_name).to_json(opts.merge(:to_json => false))
      end

      result
    end

    # Serialize a Resource to JavaScript Object Notation (JSON; RFC 4627)
    #
    # @return <String> a JSON representation of the Resource
    def to_json(*args)
      options = args.first
      options = {} unless options.kind_of?(Hash)

      result = as_json(options)

      # default to making JSON
      if options.fetch(:to_json, true)
        result.to_json
      else
        result
      end
    end

    module ValidationErrors
      module ToJson
        def to_json(*args)
          errors.to_hash.to_json
        end
      end
    end

  end


  module Associations
    # the json gem adds Object#to_json, which breaks the DM proxies, since it
    # happens *after* the proxy has been blank slated. This code removes the added
    # method, so it is delegated correctly to the Collection
    proxies = []

    proxies << ManyToMany::Proxy if defined?(ManyToMany::Proxy)
    proxies << OneToMany::Proxy  if defined?(OneToMany::Proxy)
    proxies << ManyToOne::Proxy  if defined?(ManyToOne::Proxy)

    proxies.each do |proxy|
      if proxy.public_instance_methods.any? { |m| m.to_sym == :to_json }
        proxy.send(:undef_method, :to_json)
      end
    end
  end

  class Collection
    def to_json(*args)
      options = args.first
      options = {} unless options.kind_of?(Hash)

      resource_options = options.merge(:to_json => false)
      collection = map { |resource| resource.to_json(resource_options) }

      # default to making JSON
      if options.fetch(:to_json, true)
        collection.to_json
      else
        collection
      end
    end
  end

  if Serialize.dm_validations_loaded?

    module Validations
      class ValidationErrors
        include DataMapper::Serialize::ValidationErrors::ToJson
      end
    end

  end

end
