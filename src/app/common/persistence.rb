# Implements the storage options  - right now, primarily via SharedPreferences

java_import 'android.preference.PreferenceManager'


module Persistence

  # # Calculate md5 checksum of the object. It will be calculated on the object.to_s value
  # def checksum
  #   return Digest::MD5.hexdigest(self.to_s)
  # end


  # Save a key with string value
  def save_to_shared_prefs(context, key, value)
    begin
      pref = PreferenceManager.get_default_shared_preferences(context)
      editor = pref.edit()
      editor.put_string(key.to_s, value.to_s)
      editor.commit()
      return true
    rescue Exception => e
      Logger.exception(:save_to_shared_prefs, $!)
      return false
    end
  end



  # Get a key of string value
  def get_from_shared_prefs(context, key)
    begin
      pref = PreferenceManager.get_default_shared_preferences(context)
      return pref.getString(key.to_s, nil)
    rescue Exception => e
      Logger.exception(:get_from_shared_prefs, $!)
      return nil
    end
  end

end