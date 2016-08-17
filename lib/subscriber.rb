class Subscriber

  include AutoInject["values.subscriber_value"]

  def find_by_party(event)
    subscriber_value.new(
                    name: sub[:name],
                    email: sub[:email],
                    subjects: sub[:subjects]
    )
  end

  def sub
    {
      name: "Harry Hamster",
      email: "harry@example.com",
      subjects: {
        invoice: [:email]
      }
    }
  end

end
