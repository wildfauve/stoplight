class Subscriber

  def self.find_by_party(event)
    {
      name: "Harry Hamster",
      email: "harry@example.com",
      subjects: [
        {  invoice: [:email] }
      ]
    }
  end

end
