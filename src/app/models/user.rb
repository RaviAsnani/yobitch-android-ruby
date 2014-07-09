require "app/boot"

class User
  include Net
  attr_accessor :name, :email, :gcm_token

  def initialize(name, email, gcm_token)
    @name = name
    @email = email
    @gcm_token = gcm_token
  end


  def save
    Logger.d "Stuff!"
    # TODO - change to post in actual network call
    get(BASE_SERVER, USER_GET) do |json_response|
      Logger.d json_response["messages"].first["abuse"]
    end
  end    

end