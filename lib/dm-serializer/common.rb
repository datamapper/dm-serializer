require 'dm-core'

module DataMapper
  module Serializer
    def self.dm_validations_loaded?
      DataMapper.const_defined?("Validations")
    end

    # Returns propreties to serialize based on :only or :exclude arrays,
    # if provided :only takes precendence over :exclude
    #
    # @return [Array]
    #   Properties that need to be serialized.
    def properties_to_serialize(options)
      only_properties     = Array(options[:only])
      excluded_properties = Array(options[:exclude])

      model.properties(repository.name).reject do |p|
        if only_properties.include? p.name
          false
        else
          excluded_properties.include?(p.name) ||
          !(only_properties.empty? ||
          only_properties.include?(p.name))
        end
      end
    end
  end

  Model.append_inclusions(Serializer)
end
