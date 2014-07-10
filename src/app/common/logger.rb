require "app/boot.rb"

class Logger
  def self.d(message)
    message = message + "============================================"
    Log.d(message) if DEBUG == true
  end
end