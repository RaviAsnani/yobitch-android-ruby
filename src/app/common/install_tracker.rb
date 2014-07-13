require "app/boot"

class InstallTracker < android.content.BroadcastReceiver

  def initialize(activity)
    super()
    @activity = activity
  end


  def onReceive(context, intent)
    Logger.d("On Intent")
    Logger.d(intent.get_extras().get_tring("referrer"))
  end


  def self.track_install_referrer_broadcast(activity)
    receiver = InstallTracker.new(activity)
    intent_filter = android.content.IntentFilter.new
    intent_filter.add_action('com.android.vending.INSTALL_REFERRER')
    activity.register_receiver(receiver, intent_filter)
  end

end