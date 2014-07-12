require "app/boot"

java_import 'android.content.Context'
java_import 'android.content.Intent'
java_import 'android.app.Activity'

class GcmBroadcastReceiver

  # Will get called whenever the BroadcastReceiver receives an intent.
  def onReceive(context, intent)
    registration_id = intent.get_extras.get_string("registration_id")
    $gcm.on_gcm_token_received(registration_id) if not registration_id.nil? and registration_id.length > 0

    data = intent.get_extras.get_string("data")
    if not data.nil? and data.length > 0
      $gcm.on_gcm_message_received(data)
    end
  end

end
