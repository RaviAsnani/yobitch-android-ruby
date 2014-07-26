require "app/boot"

java_import 'android.content.Context'
java_import 'android.content.Intent'
java_import 'android.app.Activity'

class GcmBroadcastReceiver

  # Will get called whenever the BroadcastReceiver receives an intent.
  # All execution here should be prepared for the fact that app might be out of memory. 
  # DO NOT depend on global variabled being available (or check hard for them!)
  def onReceive(context, intent)
    registration_id = intent.get_extras.get_string("registration_id")

    if not registration_id.nil? and registration_id.length > 0 and $gcm != nil
      $gcm.on_gcm_token_received(registration_id) 
    end

    data = intent.get_extras.get_string("data")
    if not data.nil? and data.length > 0
      Logger.d("#{context.class}", "?")
      Logger.d("#{context.get_application_context().class}", "?")
      Gcm.on_gcm_message_received(context, data)
    end
  end

end
