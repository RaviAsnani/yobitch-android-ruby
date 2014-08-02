require "app/boot"

class Message
  include Net

  attr_accessor :from, :to, :bitch_object, :on_api_call_failed

  # From user, to user, the message
  def initialize(from, to, bitch_object)
    @from = from
    @to = to
    @bitch_object = bitch_object

    @on_api_call_failed = Proc.new { |json_obj|
      Logger.d("API CALL FAILED in Message", ">")
      $main_activity.display_error_message("Unable to complete the task. Please retry!")   
    }    
  end



  # Sends the bitch message
  def send(&block)
    Logger.d("Sending message..., klass=#{@to["klass"]}")

    # Select transport based on what capability the recepient supports.
    # if klass==:starred_contact, then only SMS is supported. 
    @to["klass"] == :starred_contact ? send_sms_message(&block) : send_data_message(&block)
  end



  # Send the yobitch message via SMS connection
  def send_sms_message(&block)
    Logger.d("Sending message via SMS connection...")

    Sms.send_sms(@to["phone_number"], @from.get_invite_message(@bitch_object["abuse"]), @on_api_call_failed)
    block.call(nil)
  end



  # Send the yobitch message via data connection
  def send_data_message(&block)
    Logger.d("Sending message via data connection...")

    body = {
      :auth_token => @from.get("auth_token"),
      :receiver_id => @to["id"],
      :message_id => bitch_object["id"]
    }.to_json

    Logger.d("Message => #{body.to_s}")

    network_post(CONFIG.get(:message_send), nil, body, @on_api_call_failed) do |response|
      Logger.d(response.to_s)
      block.call(@data)
    end
  end


end



