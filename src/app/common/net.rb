require 'net/http'
require "app/boot"

module Net

  # block receives a JSON object which is just a string2json convert from the response. 
  # Make this intelligent
  def get(domain, path, &block)
    t = Thread.start do
      begin 
        response = Net::HTTP.get(domain, path)
        # Build error handling mechanism
        json_obj = JSON.parse(response)
        block.call(json_obj)
      rescue Exception
        log_exception(:net_get, $!)
      end
    end
    t.join
  end


  def log_exception(tag, exception_object)
    Logger.d "Exception in #{tag.to_s} : :\n#$!\n#{exception_object.backtrace.join("\n")}"
    Logger.d "Exception "    
  end

end