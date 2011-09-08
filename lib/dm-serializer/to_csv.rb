require 'dm-serializer/common'

if RUBY_VERSION >= '1.9.0'
 require 'csv'
else
  begin
    require 'fastercsv'
    CSV = FasterCSV
  rescue LoadError
    # do nothing
  end
end

module DataMapper
  module Serializer
    # Serialize a Resource to comma-separated values (CSV).
    #
    # @return <String> a CSV representation of the Resource
    def to_csv(*args)
      options = args.first || {}
      options = options.to_h if options.respond_to?(:to_h)
      options[:writer] = '' unless options.has_key? :writer

      CSV.generate(options[:writer]) do |csv|
        row = properties_to_serialize(options).map do |property|
          __send__(property.name).to_s
        end
        csv << row
      end
    end

    module ValidationErrors
      module ToCsv
        def to_csv(*args)
          options = args.first || {}
          options = options.to_h if options.respond_to?(:to_h)
          options[:writer] = '' unless options.has_key? :writer

          CSV.generate(options[:writer]) do |csv|
            errors.each do |key, value|
              value.each do |error|
                row = []
                row << key.to_s
                row << error.to_s
                csv << row
              end
            end
          end
        end
      end
    end
  end

  class Collection
    def to_csv(*args)
      result = ''
      each do |item|
        result << item.to_csv(args.first) + "\n"
      end
      result
    end
  end

  if const_defined?(:Validations)
    module Validations
      class ValidationErrors
        include DataMapper::Serializer::ValidationErrors::ToCsv
      end
    end
  end
end
