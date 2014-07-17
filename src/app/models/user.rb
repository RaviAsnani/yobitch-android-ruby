require "app/boot"

class User
  include Net
  include Ui
  attr_accessor :name, :email, :gcm_token, :data, :context, :ui_refresh_executor
  attr_accessor :notification_received_executor, :on_api_call_failed

  INVALID_TOKEN = "invalid_token"

  def initialize(context, name, email, gcm_token=INVALID_TOKEN)
    @context = context
    @name = name
    @email = email
    @gcm_token = gcm_token

    @data = {
      "name" => @name,
      "email" => @email,
      "gcm_token" => @gcm_token
    }

    @on_api_call_failed = Proc.new { |json_obj|
      Logger.d("API CALL FAILED in User", ">")
      $main_activity.display_error_message("Unable to complete the task. Please retry!")      
    }
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

    json = {
      :user => {
        :name => @name,
        :email => @email,
        :gcm_token => @gcm_token
      }
    }.to_json

    network_post(CONFIG.get(:user_save), nil, json, @on_api_call_failed) do |user_object|
      if is_valid_user_object?(user_object)
        @data = user_object
        Logger.d(user_object.to_s)
        block.call(@data) 
      end
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

    network_put(CONFIG.get(:user_save), nil, json, @on_api_call_failed) do |user_object|
      if is_valid_user_object?(user_object)
        @data = user_object
        Logger.d(user_object.to_s)
        block.call(@data)
      end
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


  # A method that can setup a block of code which can be requested for execution when user model updates
  # This request for execution needs to be routed via request_ui_refresh
  def listen_for_ui_refresh(&block)
    @ui_refresh_executor = block
  end


  # Should be called when the user model updates & the UI needs refreshing
  def request_ui_refresh
    @ui_refresh_executor.call
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



  # Waits to see if @data is populated in the global $user object. Then, executes a block
  # To be used by external intent broadcast receivers
  def self.wait_till_user_is_inflated(&block)
    Logger.d("Initiating wait_till_user_is_inflated")
    sleep_seconds = 3

    # In a separate thread, recursively loop till $user is not usable. Once it is, add the received friend
    t = Thread.start do
      if $user == nil or $user.get(:gcm_token) == INVALID_TOKEN
        Logger.d("Either $user is nil or gcm_token is INVALID_TOKEN. Sleeping, will check in #{sleep_seconds} seconds")
        sleep sleep_seconds
        User.wait_till_user_is_inflated(&block)
      else
        block.call
      end
    end

  end



  # Add a friend, given his ID
  def add_friend(sender_id)
    Logger.d("Got install referrer : sender_id:#{sender_id}")
    
    return if sender_id.nil? or sender_id.length == 0

    json = {
      :id => sender_id,
      :auth_token => get(:auth_token)
    }.to_json

    network_post(CONFIG.get(:add_friend), nil, json, @on_api_call_failed) do |user_object|
      if is_valid_user_object?(user_object)
        @data = user_object
        Logger.d(user_object.to_s)
        request_ui_refresh 
      end
    end    
  end



  # Get the friend object by his ID
  def get_friend_by_id(friend_id)
    friends = get(:friends)
    friends.each {|f|
       return f if f["id"] == friend_id
    }
    return nil
  end


  # Checks if the received user object is valid or not
  def is_valid_user_object?(user_object)
    return true if user_object["error"] == nil
    return false
  end

end








