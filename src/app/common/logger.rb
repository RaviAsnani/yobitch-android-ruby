require "app/boot.rb"

class Logger
  def self.d(message)
    message = message + "============================================"
    Log.d(message) if CONFIG.get(:debug) == true
  end


  # General purpose method to log exceptions
  def self.exception(tag, exception_object)
    Logger.d "Exception in #{tag.to_s} : :\n#$!\n#{exception_object.backtrace.join("\n")}"
  end

end