require 'dm-serializer/common'

module DataMapper
  module Serializer
    TAG_NAME = "ruby/DataMapper,#{DataMapper::VERSION}".freeze

    # Include a callback to register the YAML output
    #
    # @param [DataMapper::Model] descendant
    #
    # @return [undefined]
    #
    # @api private
    def self.included(descendant)
      YAML.add_domain_type(TAG_NAME, descendant.name) do |_tag, values|
        values
      end
    end

    # Serialize a Resource to YAML
    #
    # @example
    #   yaml = resource.to_yaml  # => a valid YAML string
    #
    # @param [Hash] options
    #
    # @return [String]
    #
    # @api public
    def to_yaml(options = {})
      YAML.quick_emit(object_id, options) do |out|
        out.map(to_yaml_type, to_yaml_style) do |map|
          encode_with(map, options.kind_of?(Hash) ? options : {})
        end
      end
    end unless YAML.const_defined?(:ENGINE) && !YAML::ENGINE.syck?

    # A callback to encode the resource in the YAML stream
    #
    # @param [#add] coder
    #   handles adding the values to the output
    #
    # @param [Hash] options
    #   optional Hash configuring the output
    #
    # @return [undefined]
    #
    # @api public
    def encode_with(coder, options = {})
      coder.tag   = to_yaml_type  if coder.respond_to?(:tag=)
      coder.style = to_yaml_style if coder.respond_to?(:style=)

      methods = []

      methods.concat properties_to_serialize(options).map { |property| property.name }
      methods.concat Array(options[:methods])

      methods.each do |method|
        coder.add(method.to_s, __send__(method))
      end
    end

  private

    # Return the YAML type to use for the output
    #
    # @return [String]
    #
    # @api private
    def to_yaml_type
      "!#{TAG_NAME}:#{model.name}"
    end

    # Return the YAML style to use for the output
    #
    # @return [Integer]
    #
    # @api private
    def to_yaml_style
      Psych::Nodes::Mapping::ANY
    end if YAML.const_defined?(:ENGINE) && YAML::ENGINE.yamler == 'psych'

    module ValidationErrors
      module ToYaml

        # Serialize the errors to YAML
        #
        # @example
        #   yaml = errors.to_yaml  # => a valid YAML string
        #
        # @param [Hash] options
        #
        # @return [String]
        #
        # @api public
        def to_yaml(*args)
          Hash[errors].to_yaml(*args)
        end

        # A callback to encode the errors in the YAML stream
        #
        # @param [#add] coder
        #   handles adding the values to the output
        #
        # @return [undefined]
        #
        # @api public
        def encode_with(coder)
          coder.map = Hash[errors]
        end

      end # module ToYaml
    end # module ValidationErrors

    module Collection
      module ToYaml

        # Serialize the collection to YAML
        #
        # @example
        #   yaml = collection.to_yaml  # => a valid YAML string
        #
        # @param [Hash] options
        #
        # @return [String]
        #
        # @api public
        def to_yaml(*args)
          to_a.to_yaml(*args)
        end

        # A callback to encode the collection in the YAML stream
        #
        # @param [#add] coder
        #   handles adding the values to the output
        #
        # @return [undefined]
        #
        # @api public
        def encode_with(coder)
          coder.seq = to_a
        end

      end # module ToYaml
    end # module Collection
  end # module Serializer

  class Collection
    include Serializer::Collection::ToYaml
  end # class Collection

  if const_defined?(:Validations)
    module Validations
      class ValidationErrors
        include DataMapper::Serializer::ValidationErrors::ToYaml
      end # class ValidationErrors
    end # module Validations
  end

end # module DataMapper
