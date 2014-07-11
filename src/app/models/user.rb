require "app/boot"

class User
  include Net
  attr_accessor :name, :email, :gcm_token, :data

  def initialize(name, email, gcm_token)
    @name = name
    @email = email
    @gcm_token = gcm_token
  end


  # Get user's any attribute
  def get(key)
    return @data[key]
  end


  def save(&block)
    Logger.d "Saving user"

    # TODO - change to post in actual network call
    json = {
      :user => {
        :name => @name,
        :email => @email,
        :gcm_token => @gcm_token
      }
    }.to_json

    network_post(BASE_SERVER, USER_SAVE, nil, json) do |user_object|
      @data = user_object
      Logger.d(user_object.to_s)
      block.call(@data)
    end
  end   


  def send_message(to_user_id, message)
  end 


  # Returns the whatsapp invite message - will pick a random bitch message
  def get_invite_message
    name = get("name").split(" ").first # Get the first name
    id = get("id")
    messages = get("messages")
    bitch_message = messages[(rand(messages.length-1))]["abuse"]
    return "#{name} says... #{bitch_message}!!\nIs that cool with you? B*tch him back!\nInstall Yo! B*tch app from http://#{BASE_SERVER}/#{id}/#{name}"
  end

end








