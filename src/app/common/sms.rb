require "app/boot"

java_import 'android.content.Intent'
java_import 'android.telephony.SmsManager'

module Sms

  # Starts the default SMS activity given a phone number and the text which is to be sent
  def start_sms_intent(phone_number, sms_text)
    sms_intent = Intent.new(Intent::ACTION_VIEW)
    sms_intent.set_type("vnd.android-dir/mms-sms")
    sms_intent.put_extra("address", phone_number)
    sms_intent.put_extra("sms_body", sms_text)
    start_activity(sms_intent)    
  end


  # Sends SMS, given a phone number and the text which is to be sent
  def send_sms(phone_number, sms_text)
    begin
      sms_manager = SmsManager::getDefault
      sms_manager.send_text_message(phone_number, nil, sms_text, nil, nil)
    rescue
      Logger.exception(:sms_send_sms, $!)
    end
  end

end