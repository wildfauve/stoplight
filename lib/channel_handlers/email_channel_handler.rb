class EmailChannelHandler

  def call(event: , subscriber:, template:)
    puts "EMAIL Channel"
    puts "Sending to: #{subscriber.email}"
    puts "Template: #{template.name}"
    puts "Template Values: #{template.template_values}"
  end


end
