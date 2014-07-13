require "app/boot"

class Message
  include Net

  attr_accessor :from, :to, :message

  # From user, to user, the message
  def initialize(from, to, message)
    @from = from
    @to = to
    @message = message
  end


  def send(&block)
    body = {
      :auth_token => @from.get("auth_token"),
      :receiver_id => @to["id"],
      :message_id => message["id"]
    }.to_json
    
    network_post("yobitch.me", "/api/v1/users/send_message", nil, body) do |response|
      Logger.d(response.to_s)
      block.call(@data)
    end
  end
end