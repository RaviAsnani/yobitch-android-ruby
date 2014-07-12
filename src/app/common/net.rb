require 'net/http'
require "uri"

require "app/boot"

module Net

  # block receives a JSON object which is just a string2json convert from the response. 
  # Make this intelligent
  def network_get(domain, path, &block)
    t = Thread.start do
      begin 
        response = Net::HTTP.get(domain, path)

        # Build error handling mechanism
        json_obj = JSON.parse(response)
        block.call(json_obj)  
      rescue Exception
        Logger.exception(:net_get, $!)
      end
    end
    t.join
  end



  # params, json_body can be optionally nil
  def network_post(domain, path, params, json_body, &block)
    t = Thread.start do
      Logger.d("Starting post")
      begin
        uri = URI.parse(CONFIG.get(:scheme) + domain + path)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(params) if params != nil
        request.body = json_body if json_body != nil
        request["Content-Type"] = "application/json"
        response = http.request(request)

        # Build error handling mechanism
        json_obj = JSON.parse(response.body)
        Logger.d(response.body)
        block.call(json_obj)  
      rescue Exception
        Logger.exception(:net_post, $!)
      end
    end
    t.join
  end


  # params, json_body can be optionally nil
  def network_put(domain, path, params, json_body, &block)
    t = Thread.start do
      Logger.d("Starting put")
      begin
        uri = URI.parse(CONFIG.get(:scheme) + domain + path)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Put.new(uri.request_uri)
        request.set_form_data(params) if params != nil
        request.body = json_body if json_body != nil
        request["Content-Type"] = "application/json"
        response = http.request(request)

        # Build error handling mechanism
        json_obj = JSON.parse(response.body)
        Logger.d(response.body)
        block.call(json_obj)  
      rescue Exception
        Logger.exception(:net_post, $!)
      end
    end
    t.join
  end  


end







# require "net/http"
# require "uri"
# require "json"
# uri = URI.parse("http://" + "yobitch.me" + "/api/v1/users/send_message?auth_token=67c09bdeeffd6a1860a1fb38c8841ef8")
# params = {
#       :auth_token => "67c09bdeeffd6a1860a1fb38c8841ef8"
# }

# json_body = {
#   :receiver_id => 2,
#   :message_id => 1
# }.to_json

# http = Net::HTTP.new(uri.host, uri.port)
# request = Net::HTTP::Post.new(uri.request_uri)
# #request.set_form_data(params) if params != nil
# request.body = json_body if json_body != nil
# request["Content-Type"] = "application/json"
# response = http.request(request)

# puts response.body


