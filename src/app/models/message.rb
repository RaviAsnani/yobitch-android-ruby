require "app/boot"

class Message
  include Net

  attr_accessor :from, :to, :message, :on_api_call_failed

  # From user, to user, the message
  def initialize(from, to, message)
    @from = from
    @to = to
    @message = message

    @on_api_call_failed = Proc.new { |json_obj|
      Logger.d("API CALL FAILED in Message", ">")
      $main_activity.display_error_message("Unable to complete the task. Please retry!")   
    }    
  end


  def send(&block)
    Logger.d("Sending message...")
    body = {
      :auth_token => @from.get("auth_token"),
      :receiver_id => @to["id"],
      :message_id => message["id"]
    }.to_json

    Logger.d("Message => #{body.to_s}")

    network_post(CONFIG.get(:message_send), nil, body, @on_api_call_failed) do |response|
      Logger.d(response.to_s)
      block.call(@data)
    end
  end
end