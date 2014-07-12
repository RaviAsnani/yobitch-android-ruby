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
  class Notification
    def self.build(context, bitch_message)
      builder = NotificationCompat::Builder.new(context)
                  .set_small_icon($package.R::drawable::shout)
                  .set_content_title(bitch_message["message"])
                  .set_content_text(bitch_message["title"]);

      notification_manager = context.get_system_service(Context::NOTIFICATION_SERVICE)
      notification_manager.notify(1, builder.build())
    end
  end


end