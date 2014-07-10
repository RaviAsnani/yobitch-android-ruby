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
      :receiver_id => @to["id"],
      :message_id => message["id"]
    }.to_json
    
    Logger.d(body.to_s)

    network_post("yobitch.me", "/api/v1/users/send_message?auth_token=#{@from.get("auth_token")}", nil, body) do |response|
      Logger.d(response.to_s)
      block.call(@data)
    end
  end
end