require "app/boot"

class Logger
  def self.d(message, keyword="=")
    tail = "============================================"
    tail.gsub!("=", keyword) if keyword != "="
    message = message.to_s + tail
    Log.d(message) if CONFIG.get(:debug) == true
  end


  # General purpose method to log exceptions
  def self.exception(tag, exception_object)
    exception_text = exception_object.backtrace.join("\n")

    # Track exceptions in GA (just for the kicks of it)
    if not $main_activity.nil?
      Analytics.new($main_activity, CONFIG.get(:ga_tracking_id))
                .fire_event({:category => "exception", :action => tag.to_s, :label => exception_text})    
    end

    Logger.d "Exception in #{tag.to_s} : :\n#$!\n#{exception_text}"
  end

end