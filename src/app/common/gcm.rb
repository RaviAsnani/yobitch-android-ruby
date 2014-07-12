require "app/boot"

java_import 'com.google.android.gms.gcm.GoogleCloudMessaging'
java_import 'com.google.android.gms.common.ConnectionResult'
java_import 'com.google.android.gms.common.GooglePlayServicesUtil'

# TODO
# 1. Implement shared preferences and save the fetched gcm registration id into that

class Gcm

  attr_accessor :context, :sender_id, :registration_id, :user_object

  def initialize(context, sender_id, user_object)
    @context = context
    @sender_id = sender_id
    @registration_id = nil
    @user_object = user_object

    check_google_services
    register
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
    gcm = GoogleCloudMessaging.get_instance(@context)

    t = Thread.start do
      begin
        @registration_id = gcm.register(@sender_id)

        if not @registration_id.nil? && @registration_id != ""
          Logger.d("GCM Token received in actual Gcm.register call... Yay! Saving it to user object")
          # It's a hack to call the on_gcm_registration_received on a global user object
          user_object.on_gcm_registration_received(@registration_id) if not user_object.nil?
          Logger.d("~~~~~~~#{@registration_id}~~~~~~~~~")
        end
      rescue Exception
        Logger.exception(:gcm_register, $!)
      end
    end
    t.join
  end

end


