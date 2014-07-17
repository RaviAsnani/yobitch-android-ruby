require "app/boot"

java_import 'com.google.android.gms.gcm.GoogleCloudMessaging'
java_import 'com.google.android.gms.common.ConnectionResult'
java_import 'com.google.android.gms.common.GooglePlayServicesUtil'

# TODO
# 1. Implement shared preferences and save the fetched gcm registration id into that
# 2. Depends on a $user object present in the system

class Gcm

  attr_accessor :context, :sender_id, :gcm_token, :user_object

  def initialize(context, sender_id, user_object)
    @context = context
    @sender_id = sender_id
    @gcm_token = nil
    @user_object = user_object
  end



  # Checks if google play services are available
  def check_google_services
    result_code = GooglePlayServicesUtil.is_google_play_services_available(@context)
    Logger.d("check_google_services : #{result_code.to_s} - which is #{result_code == ConnectionResult::SUCCESS}")
    return result_code != ConnectionResult::SUCCESS ? false : true
  end



  # Register for GCM registration ID
  # NOTE - gcm.register will always generate the SERVICE_NOT_AVAILABLE message but the token will be 
  # always received in GcmBroadcastReceiver class. From there, it needs to be channelized into user model
  # This is a possible bug in google play services - I don't know.
  # gcm.register cannot be removed - this is what initiated the process. NEVER remove it!
  def register
    check_google_services
    gcm = GoogleCloudMessaging.get_instance(@context)

    t = Thread.start do
      begin
        @gcm_token = gcm.register(@sender_id)

        if not @gcm_token.nil? && @gcm_token != ""
          Logger.d("GCM Token received in actual Gcm.register call... Yay! Saving it to user object")
          # It's a hack to call the on_gcm_registration_received on a global user object
          user_object.on_gcm_token_received(@gcm_token) if not user_object.nil?
          Logger.d("~~~~~~~#{@gcm_token}~~~~~~~~~")
        end
      rescue Exception
        Logger.exception(:gcm_register, $!)
      end
    end
    #t.join
  end


  # Relays the gcm token id to the user object if the user exists
  def on_gcm_token_received(gcm_token)
    return if (gcm_token.nil? or gcm_token.length == 0)
    Logger.d("In Gcm, got GCM token. Relaying it to user object. gcm_token : #{gcm_token}")
    $user.on_gcm_token_received(gcm_token) if not $user.nil?
  end



  # Relayes the gcm message to user if it exists
  def on_gcm_message_received(gcm_message)
    return if (gcm_message.nil? or gcm_message.length == 0)
    Logger.d("In Gcm, got GCM message. Relaying it to user object. gcm_message : #{gcm_message}")
    $user.on_gcm_message_received(gcm_message) if not $user.nil?
  end

end


