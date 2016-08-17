require './lib/types'

class SubscriberValue < Dry::Types::Struct

  attribute :name, Types::String
  attribute :email, Types::String
  attribute :subjects, Types::Hash

end
