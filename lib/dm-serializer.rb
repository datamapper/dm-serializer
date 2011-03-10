require 'dm-serializer/to_json'
require 'dm-serializer/to_xml'
require 'dm-serializer/to_yaml'
require 'dm-serializer/to_csv'

module DataMapper
  # Define the `Serialize` constant for backwards compatibility.
  #
  # @note
  #   The `Serialize` constant will be removed soon, please use
  #   {Serializer} instead.
  #
  Serialize = Serializer
end
