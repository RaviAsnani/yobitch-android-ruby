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
    network_get(BASE_SERVER, USER_GET) do |user_object|
      @data = user_object
      Logger.d @data["messages"].first["abuse"]
      block.call(@data)
    end
  end   


  def send_message(to_user_id, message)

  end 

end