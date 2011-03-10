require 'dm-serializer/common'

module DataMapper
  module Serializer
    # Serialize a Resource to YAML
    #
    # @return [YAML]
    #   A YAML representation of this Resource.
    def to_yaml(opts_or_emitter = {})
      unless opts_or_emitter.is_a?(Hash)
        emitter = opts_or_emitter
        opts = {}
      else
        emitter = {}
        opts = opts_or_emitter
      end

      YAML.quick_emit(object_id,emitter) do |out|
        out.map(nil,to_yaml_style) do |map|
          properties_to_serialize(opts).each do |property|
            value = __send__(property.name.to_sym)
            map.add(property.name, value.is_a?(Class) ? value.to_s : value)
          end

          # add methods
          Array(opts[:methods]).each do |meth|
            if respond_to?(meth)
              map.add(meth.to_sym, __send__(meth))
            end
          end

          if (additions = instance_variable_get("@yaml_addes"))
            additions.each { |k,v| map.add(k.to_s,v) }
          end
        end
      end
    end

    module ValidationErrors
      module ToYaml
        def to_yaml(*args)
          DataMapper::Ext::Array.to_hash(errors).to_yaml(*args)
        end
      end
    end

  end

  class Collection
    def to_yaml(opts_or_emitter = {})
      unless opts_or_emitter.is_a?(Hash)
        to_a.to_yaml(opts_or_emitter)
      else
        # FIXME: Don't double handle the YAML (remove the YAML.load)
        to_a.collect { |x| YAML.load(x.to_yaml(opts_or_emitter)) }.to_yaml
      end
    end
  end

  if Serializer.dm_validations_loaded?

    module Validations
      class ValidationErrors
        include DataMapper::Serializer::ValidationErrors::ToYaml
      end
    end

  end
end
