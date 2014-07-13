require "app/boot"

class User
  include Net
  include Ui
  attr_accessor :name, :email, :gcm_token, :data, :context

  def initialize(context, name, email, gcm_token="invalid")
    @context = context
    @name = name
    @email = email
    @gcm_token = gcm_token

    @data = {
      "name" => @name,
      "email" => @email,
      "gcm_token" => @gcm_token
    }
  end


  # def experiment(intent)
  #   Logger.d("@@@@@@@@@@@@@@@@@" + intent.get_extras.get_string("data").to_s)
  # end

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
  def on_gcm_token_received(gcm_token)
    Logger.d("In User, got GCM token : gcm_token : #{gcm_token}")
    
    if get(:gcm_token) != gcm_token
      Logger.d("Received GCM token is different than what was present. Will update")
      set(:gcm_token, gcm_token)

      # save the GCM token on server now
      update { |user_object|
        Logger.d("User's gcm_token is now saved on server.")
        Logger.d(user_object.to_s)
      }
    else
      Logger.d("Received GCM token is same as what was present. Will NOT update")
    end
  end



  # To be called when GCM message is received from the server
  def on_gcm_message_received(gcm_message)
    Logger.d("In User, got GCM message : gcm_message : #{gcm_message.to_s}")
    message = JSON.parse(gcm_message)
    @notification_received_executor.call(message)
  end  


  # Sets up a reference of a block which should execute on main UI when a notification is received
  def listen_for_notification_received(&block)
    @notification_received_executor = block
  end


  # Sends message to a friend
  # friend_object, bitch_object => parts of the @user object which represent the mentioned friend & bitch
  def send_message(friend_object, bitch_object, &block)
    Message.new(self, friend_object, bitch_object).send(&block)
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








