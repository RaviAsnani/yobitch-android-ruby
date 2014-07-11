require "app/boot"

java_import 'android.content.Intent'

module ShareManager

  def share_via_whatsapp(share_text)
    Logger.d("Init sharing via whatsapp")
    intent = Intent.new(Intent::ACTION_SEND)
    intent.setType("text/plain")

    intent.set_package("com.whatsapp")

    if intent != nil
      Logger.d("Found Whatsapp, trying to share")
      intent.put_extra(Intent::EXTRA_TEXT, share_text);
      start_activity(Intent.create_chooser(intent, "Share with"));
    else
      Logger.d("Whatsapp is not installed")
    end
  end

end