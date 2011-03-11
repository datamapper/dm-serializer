require 'dm-serializer/common'
require 'dm-serializer/xml'

module DataMapper
  module Serializer
    # Serialize a Resource to XML.
    #
    # @return [LibXML::Document, Nokogiri::Document, REXML::Document]
    #   An XML representation of this Resource.
    #
    def to_xml(opts = {})
      xml = XML.serializer
      xml.output(to_xml_document(opts)).to_s
    end

    # This method requires certain methods to be implemented in the
    # individual  serializer library subclasses:
    #
    # * new_document
    # * root_node
    # * add_property_node
    # * add_node
    def to_xml_document(opts={}, doc = nil)
      xml = XML.serializer
      doc ||= xml.new_document

      default_xml_element_name = lambda {
        DataMapper::Inflector.underscore(model.name).tr("/", "-")
      }

      root = xml.root_node(
        doc,
        (opts[:element_name] || default_xml_element_name[])
      )

      properties_to_serialize(opts).each do |property|
        value = __send__(property.name)
        attrs = {}

        unless property.primitive == String
          attrs['type'] = property.primitive.to_s.downcase
        end

        xml.add_node(root, property.name.to_s, value, attrs)
      end

      Array(opts[:methods]).each do |meth|
        if self.respond_to?(meth)
          xml_name = meth.to_s.gsub(/[^a-z0-9_]/, '')
          value = __send__(meth)

          unless value.nil?
            if value.respond_to?(:to_xml_document)
              xml.add_xml(root, value.to_xml_document)
            else
              xml.add_node(root, xml_name, value.to_s)
            end
          end
        end
      end

      doc
    end

    module ValidationErrors
      module ToXml
        def to_xml(opts = {})
          to_xml_document(opts).to_s
        end

        def to_xml_document(opts = {})
          xml = DataMapper::Serializer::XML.serializer
          doc = xml.new_document
          root = xml.root_node(doc, "errors", {'type' => 'hash'})

          errors.each do |key, value|
            property = xml.add_node(root, key.to_s, nil, {'type' => 'array'})
            property.attributes["type"] = 'array'

            value.each do |error|
              xml.add_node(property, "error", error)
            end
          end

          doc
        end
      end
    end

  end

  class Collection
    def to_xml(opts = {})
      to_xml_document(opts).to_s
    end

    def to_xml_document(opts = {})
      xml = DataMapper::Serializer::XML.serializer
      doc = xml.new_document

      default_collection_element_name = lambda {
        DataMapper::Inflector.pluralize(DataMapper::Inflector.underscore(self.model.to_s)).tr("/", "-")
      }

      root = xml.root_node(
        doc,
        opts[:collection_element_name] || default_collection_element_name[],
        {'type' => 'array'}
      )

      self.each do |item|
        item.to_xml_document(opts, doc)
      end

      doc
    end
  end

  if Serializer.dm_validations_loaded?

    module Validations
      class ValidationErrors
        include DataMapper::Serializer::ValidationErrors::ToXml
      end
    end

  end
end
