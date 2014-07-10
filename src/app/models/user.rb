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

end