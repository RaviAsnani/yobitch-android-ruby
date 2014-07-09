require "app/config"
require "httparty"

class User
  attr_accessor :name, :email, :gcm_token

  def initialize(name, email, gcm_token)
    @name = name
    @email = email
    @gcm_token = gcm_token
  end


  def save
    Log.d("Stuff!")
  end
    

end