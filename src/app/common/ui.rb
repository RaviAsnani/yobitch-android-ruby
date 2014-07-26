require 'ruboto/widget'
require 'ruboto/util/toast'


java_import 'android.app.ProgressDialog'
java_import 'android.widget.Toast'

java_import 'android.app.PendingIntent'
java_import 'android.content.Intent'
java_import 'android.support.v4.app.NotificationCompat'
java_import 'android.os.Bundle'
java_import 'android.media.RingtoneManager'


module Ui

  # Progress dialog
  class UiProgressDialog
    attr_accessor :progress_dialog, :context
    DEFAULT_WAIT_MESSAGE = "Yo! Please wait..."

    def initialize(context)
      @context = context
      @progress_dialog = ProgressDialog.new(context)
      @progress_dialog.set_message(DEFAULT_WAIT_MESSAGE)
      @progress_dialog.set_cancelable(false)
      @progress_dialog.set_indeterminate(true)    
    end

    def show(message = nil)
      message = message.nil? ? DEFAULT_WAIT_MESSAGE : message
      @progress_dialog.set_message(message)
      @progress_dialog.show
    end

    def hide
      @progress_dialog.dismiss
    end
  end



  # Toast message
  class UiToast
    def self.show(activity, text)
      Toast.make_text(activity, text, Toast::LENGTH_SHORT).show
    end
  end



  # Push notification
  # TODO - notification info right now is part of set_action call to intent. It should ideally be part of
  # put_extra method on the intent (which is not working somehow... sob sob)
  class UiNotification

    # Clears all notifications
    def self.cancel_all(context)
      notification_manager = context.get_system_service(Context::NOTIFICATION_SERVICE)
      notification_manager.cancel_all
    end



    # notification_data["klass"] => "bitch" || "friend_add"
    def self.build(context, notification_data)
      sound_uri = RingtoneManager::get_default_uri(RingtoneManager::TYPE_NOTIFICATION)

      # Data, Intent & Pending intent to open app
      open_intent = Intent.new
      open_intent.setClassName($package_name, 'com.rum.yobitch.MainActivity')
      open_intent.set_action("notification_open:#{notification_data["sender"]["id"]}")
      pending_open_intent = PendingIntent::getActivity(context, 0, open_intent, 0);

      builder = NotificationCompat::Builder.new(context)
                  .set_small_icon(Ruboto::R::drawable::shout)
                  .set_content_title(notification_data["message"])
                  .set_content_text(notification_data["title"])
                  .set_content_intent(pending_open_intent)
                  .set_sound(sound_uri)
                  

      # If the notification klass==bitch, then build the additional action of random bitch
      if notification_data["klass"] == "bitch"
        # Data, Intent & Pending intent to send back a random bitch
        random_intent = Intent.new
        random_intent.setClassName($package_name, 'com.rum.yobitch.MainActivity')
        random_intent.set_action("notification_random_bitch:#{notification_data["sender"]["id"]}")
        pending_random_intent = PendingIntent::getActivity(context, 0, random_intent, 0)

        builder.add_action(Ruboto::R::drawable::reply, "Reply with a random B*tch!", pending_random_intent)
      end
         
      # Finally build the notification       
      builder = builder.build()

      builder.flags |= android.app.Notification::FLAG_AUTO_CANCEL;

      notification_manager = context.get_system_service(Context::NOTIFICATION_SERVICE)
      notification_manager.notify(1, builder)
    end
  end


end