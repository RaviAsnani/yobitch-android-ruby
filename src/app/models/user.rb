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
  # key can be a string or a symbol which is converted to string before being used
  def get(key)
    return @data[key.to_s]
  end


  # Set user's any attribute
  # key can be a string or a symbol which is converted to string before being used  
  def set(key, value=nil)
    @data[key.to_s] = value
  end


  # Save the user on server
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

    network_post(CONFIG.get(:domain), CONFIG.get(:user_save), nil, json) do |user_object|
      @data = user_object
      Logger.d(user_object.to_s)
      block.call(@data)
    end
  end


  # Update the user on server
  def update(&block)
    Logger.d "Updating user"

    # TODO - change to post in actual network call
    json = {
      :user => {
        :name => get(:name),
        :email => get(:email),
        :gcm_token => get(:gcm_token)
      },
      :auth_token => get(:auth_token)
    }.to_json

    network_put(CONFIG.get(:domain), CONFIG.get(:user_save), nil, json) do |user_object|
      @data = user_object
      Logger.d(user_object.to_s)
      block.call(@data)
    end
  end


  # To be called when GCM token is received while gcm registration
  def on_gcm_registration_received(gcm_token)
    Logger.d("In User, got GCM token : gcm_token : #{gcm_token}")
    set(:gcm_token, gcm_token)

    # save the GCM token on server now
    update { |user_object|
      Logger.d("User's gcm_token is now saved on server.")
      Logger.d(user_object.to_s)
    }
  end


  def send_message(to_user_id, message)
  end 


  # Returns the whatsapp invite message - will pick a random bitch message
  def get_invite_message
    name = get("name").split(" ").first # Get the first name
    id = get("id")
    messages = get("messages")
    bitch_message = messages[(rand(messages.length-1))]["abuse"]
    return "#{name} says... #{bitch_message}!!\nIs that cool with you? B*tch him back!\nInstall Yo! B*tch app from http://#{CONFIG.get(:domain)}/#{id}/#{name}"
  end

end








