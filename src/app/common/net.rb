require 'net/http'
require "uri"

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



  def post(domain, path, json_string, &block)
    t = Thread.start do
      begin
        uri = URI.parse(SCHEME + domain + path)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = json_string
        request["Content-Type"] = "application/json"
        response = http.request(request)

        # Build error handling mechanism
        json_obj = JSON.parse(response.body)
        block.call(json_obj)  
      rescue Exception
        log_exception(:net_post, $!)
      end
    end
    t.join
  end


  private

  def parse_json_string(json_string, &block)
  
  end


  def log_exception(tag, exception_object)
    Logger.d "Exception in #{tag.to_s} : :\n#$!\n#{exception_object.backtrace.join("\n")}"
    Logger.d "Exception "    
  end

end