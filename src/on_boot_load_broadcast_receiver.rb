require "app/boot"
require "on_boot_load_service"

java_import 'android.content.Context'
java_import 'android.content.Intent'
java_import 'android.app.Activity'

class OnBootLoadBroadcastReceiver

  # Will get called whenever the BroadcastReceiver receives an intent.
  def onReceive(context, intent)
    # use this to start and trigger a service
    #intent = Intent.new(context, OnBootLoadService.class)

    intent = Intent.new
    intent.setClassName(context, 'com.rum.yobitch.OnBootLoadService')    
    
    # potentially add data to the intent
    intent.put_extra("key", "Value")
    context.start_service(intent)
  end

end
