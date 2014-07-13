require "app/boot"
require "app/models/user"
require "uri"

java_import 'android.content.Context'
java_import 'android.content.Intent'
java_import 'android.app.Activity'

class InstallReferrerBroadcastReceiver

  # Will get called whenever the BroadcastReceiver receives an intent.
  def onReceive(context, intent)
    Logger.d("On INSTALL_REFERRER intent")
    referrer = intent.get_extras().get_string("referrer")
    Logger.d(referrer)

    return if referrer == nil && referrer.length == 0

    begin
      referrer = URI.decode(referrer)
      data = JSON.parse(referrer)

      User.wait_till_user_is_inflated do
        $user.add_friend(data["sender_id"])
      end
    rescue Exception
      Logger.exception(:InstallReferrerBroadcastReceiver_onRecieve, $!)
    end
  end


end
