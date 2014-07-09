require "app/config"
require "app/common/net"

import org.ruboto.Log

class User
  include Net
  attr_accessor :name, :email, :gcm_token

  def initialize(name, email, gcm_token)
    @name = name
    @email = email
    @gcm_token = gcm_token
    Log.d(@gcm_token)
  end


  def save
    Log.d "Stuff!"
    get("10.90.21.14", "/user_post.json", {}, &method(:save_success))
    #post(&method(:save_success))
  end

  def save_success(response)
    Log.d response
  end
    

end