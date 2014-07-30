require "app/boot"

java_import 'android.content.Intent'

module Sms

  # Starts the default SMS activity given a phone number and the text which is to be sent
  def start_sms_intent(phone_number, sms_text)
    sms_intent = Intent.new(Intent::ACTION_VIEW)
    sms_intent.set_type("vnd.android-dir/mms-sms")
    sms_intent.put_extra("address", phone_number)
    sms_intent.put_extra("sms_body", sms_text)
    start_activity(sms_intent)    
  end

end