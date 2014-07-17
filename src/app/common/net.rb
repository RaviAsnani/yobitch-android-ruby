require 'net/http'
require "uri"

require "app/boot"

module Net

  NETWORK_SUCCESS = "200"

  # block receives a JSON object which is just a string2json convert from the response. 
  # Make this intelligent
  def network_get(path, error_block, &success_block)
    domain = CONFIG.get(:domain)
    t = Thread.start do
      begin 
        uri = URI.parse(CONFIG.get(:scheme) + domain + path)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        check_network_response(response, error_block, &success_block)
      rescue Exception
        Logger.exception(:net_get, $!)
        error_block.call
      end
    end
    #t.join
  end



  # params, json_body can be optionally nil
  def network_post(path, params, json_body, error_block, &success_block)
    domain = CONFIG.get(:domain)
    t = Thread.start do
      Logger.d("Starting post")
      begin
        uri = URI.parse(CONFIG.get(:scheme) + domain + path)
        Logger.d(uri.to_s)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(params) if params != nil
        request.body = json_body if json_body != nil
        request["Content-Type"] = "application/json"
        response = http.request(request)

        check_network_response(response, error_block, &success_block)
      rescue Exception
        Logger.exception(:net_post, $!)
        error_block.call
      end
    end
    #t.join
  end


  # params, json_body can be optionally nil
  def network_put(path, params, json_body, error_block, &success_block)
    domain = CONFIG.get(:domain)
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

        check_network_response(response, error_block, &success_block)
      rescue Exception
        Logger.exception(:net_put, $!)
        error_block.call
      end
    end
    #t.join
  end  




  private


  # Checks to see if the network response was a success - then execute the success block, else the error block
  # On exception in response parsing - still calls the error block
  # error_block is optional
  def check_network_response(response, error_block, &success_block)
    
    if error_block == nil
      error_block = Proc.new { |json_obj|
        Logger.d("Invoked default error block from check_network_response")
      }
    end

    begin
      json_obj = JSON.parse(response.body)

      if response.code.to_s != NETWORK_SUCCESS
        Logger.d("Network call failed with HTTP_CODE=#{response.code} - invoking error block")
        Logger.d(json_obj.to_s)
        error_block.call(json_obj)
      else
        Logger.d("Network call was a success - invoking success block")
        Logger.d(json_obj.to_s)
        success_block.call(json_obj)
      end
    rescue Exception
      Logger.d("Exception in parsing output from the network. Invoking error block")
      Logger.exception(:check_network_response, $!)
      error_block.call
    end

  end


end







# require "net/http"
# require "uri"
# require "json"
# uri = URI.parse("http://yobitch.me/api/v1/users")
# json_body = {
#   :name => "q1",
#   :email => "q2@gmail.com",
#   :gcm_token => "q3"
# }.to_json

# http = Net::HTTP.new(uri.host, uri.port)
# request = Net::HTTP::Post.new(uri.request_uri)
# request.body = json_body if json_body != nil
# request["Content-Type"] = "application/json"
# response = http.request(request)

# puts response.body


