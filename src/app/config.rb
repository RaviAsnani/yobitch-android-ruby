ENV = :production   # This variable governs all config

class Config

  attr_accessor :keys, :env

  def initialize(env=:production)
    @env = env

    @keys = {
      :production => {
          :debug => true,
          :scheme => "http://",
          :domain => "yobitch.me",
          :user_get => "/user_post.json",
          :user_save => "/api/v1/users",
          :user_post => "/api/v1/users/send_message",
          :gcm_sender_id => "77573904884",
          :package_name => "com.rum.yobitch"
        },
        :development => {
          :debug => true,
          :scheme => "http://",
          :domain => "192.168.43.186",
          :user_get => "/user_post.json",
          :user_save => "/user_post.json",
          :user_post => "/api/v1/users/send_message",
          :gcm_sender_id => "77573904884",
          :package_name => "com.rum.yobitch"
        }
    }
  end


  # General purpose getter
  def get(key)
    return @env if key == :env

    value = @keys[@env][key]
    raise("Invalid config requested") if value.nil?

    return value
  end

end

# Global object to be used everywhere
CONFIG = Config.new(ENV)
