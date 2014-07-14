java_import 'android.app.ProgressDialog'
java_import 'android.widget.Toast'

java_import 'android.app.PendingIntent'
java_import 'android.content.Intent'
java_import 'android.support.v4.app.NotificationCompat'
#java_import 'android.support.v4.app.NotificationCompat.Builder'



module Ui

  # Progress dialog
  class UiProgressDialog
    attr_accessor :progress_dialog, :context

    def initialize(context)
      @context = context
      @progress_dialog = ProgressDialog.new(context)
      @progress_dialog.set_message("Yo! Please wait...")
      @progress_dialog.set_cancelable(false)
      @progress_dialog.set_indeterminate(true)    
    end

    def show
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
  class UiNotification
    def self.build(context, bitch_message)
      # Intent & Pending intent to open app
      open_intent = Intent.new
      open_intent.setClassName($package_name, 'com.rum.yobitch.MainActivity')
      open_intent.put_extra("klass", "notification_open")
      open_intent.put_extra("bitch_message", bitch_message.to_json)      
      pending_open_intent = PendingIntent::getActivity(context, 0, open_intent, 0);

      # Intent & Pending intent to send back a random bitch
      random_intent = Intent.new
      random_intent.setClassName($package_name, 'com.rum.yobitch.MainActivity')
      random_intent.put_extra("klass", "notification_random_bitch")
      random_intent.put_extra("bitch_message", bitch_message.to_json)
      pending_random_intent = PendingIntent::getActivity(context, 0, random_intent, 0)

      builder = NotificationCompat::Builder.new(context)
                  .set_small_icon($package.R::drawable::shout)
                  .set_content_title(bitch_message["message"])
                  .set_content_text(bitch_message["title"])
                  .set_content_intent(pending_open_intent)
                  .add_action($package.R::drawable::reply, "Reply with a random B*tch!", pending_random_intent)
                  .build()

      builder.flags |= android.app.Notification::FLAG_AUTO_CANCEL;

      notification_manager = context.get_system_service(Context::NOTIFICATION_SERVICE)
      notification_manager.notify(1, builder)
    end
  end


end