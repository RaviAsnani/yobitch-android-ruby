require 'net/http'
require "app/config"

import org.ruboto.Log

# java_import 'android.net.http.AndroidHttpClient'
# java_import 'android.util.Log'
# java_import 'org.apache.http.client.entity.UrlEncodedFormEntity'
# java_import 'org.apache.http.client.methods.HttpPost'
# java_import 'org.apache.http.message.BasicNameValuePair'
# java_import 'org.apache.http.util.EntityUtils'

module Net

  def get(domain, path, params_hash={}, &success_callback)
    t = Thread.start do
      begin 
        response = Net::HTTP.get(domain, path)
        success_callback.call(response)
      rescue Exception
        Log.d "Exception in Net.get!"
      end
    end
    t.join
  end


  # def post(&success_callback)
  #   t = Thread.start do
  #     begin
  #       client = AndroidHttpClient.newInstance('yobitch')
  #       method = HttpPost.new("http://10.90.21.14/user_post.json")
  #       method.setHeader("Content-Type", "application/json");
  #       list   = [BasicNameValuePair.new('order[amount]', '42'), BasicNameValuePair.new('order[product_id]', '37')]
  #       entity = UrlEncodedFormEntity.new(list)
  #       method.setEntity(entity)
  #       response = EntityUtils.toString(client.execute(method).entity)

  #       success_callback.call(response)
  #     rescue Exception
  #       Log.d "Exception in Net.get!"
  #       Log.i "Exception in task:\n#$!\n#{$!.backtrace.join("\n")}"
  #     ensure
  #       client.close if client
  #     end
  #   end
  #   t.join    
  # end

end