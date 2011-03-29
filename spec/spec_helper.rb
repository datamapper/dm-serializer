require 'dm-core/spec/setup'
require 'dm-core/spec/lib/adapter_helpers'
require 'dm-core/spec/lib/pending_helpers'

require 'dm-validations' # FIXME: must be required before dm-serializer
require 'dm-serializer'
require 'dm-migrations'

require File.expand_path('spec/lib/serialization_method_shared_spec')

# require fixture resources
SPEC_ROOT = Pathname(__FILE__).dirname.expand_path
Pathname.glob((SPEC_ROOT + 'fixtures/**/*.rb').to_s).each { |file| require file }

class SerializerTestHarness
  def test(object, *args)
    deserialize(object.send(method_name, *args))
  end
end

DataMapper::Spec.setup

Spec::Runner.configure do |config|
  config.extend(DataMapper::Spec::Adapters::Helpers)
  config.include(DataMapper::Spec::PendingHelpers)
end
