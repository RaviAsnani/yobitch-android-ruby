require "app/boot"

java_import 'com.google.android.gms.gcm.GoogleCloudMessaging'
java_import 'com.google.android.gms.common.ConnectionResult'
java_import 'com.google.android.gms.common.GooglePlayServicesUtil'

# TODO
# 1. Implement shared preferences and save the fetched gcm registration id into that

class Gcm

  attr_accessor :context, :sender_id, :registration_id

  def initialize(context, sender_id)
    @context = context
    @sender_id = sender_id
    @registration_id = nil
    check_google_services
  end


  # Checks if google play services are available
  def check_google_services
    result_code = GooglePlayServicesUtil.is_google_play_services_available(@context)
    Logger.d("check_google_services : #{result_code.to_s} - which is #{result_code == ConnectionResult::SUCCESS}")
    return result_code != ConnectionResult::SUCCESS ? false : true
  end



  # Register for GCM registration ID
  def register
    gcm = GoogleCloudMessaging.get_instance(@context)

    t = Thread.start do
      begin
        @registration_id = gcm.register(@sender_id)
        Logger.d("~~~~~~~#{@registration_id}~~~~~~~~~")
      rescue Exception
        Logger.exception(:gcm_register, $!)
      end
    end
    t.join
  end

end