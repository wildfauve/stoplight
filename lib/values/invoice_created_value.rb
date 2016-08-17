require './lib/types'

class InvoiceCreatedValue < Dry::Types::Struct

  attribute :kind, Types::Symbol
  attribute :party_url, Types::String
  attribute :amount, Types::Float
  attribute :invoice_date, Types::String

end
