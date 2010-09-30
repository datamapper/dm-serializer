class Vehicle
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :type, Discriminator
end

class Car < Vehicle

end

class Motorcycle < Vehicle

end
