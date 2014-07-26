ENV = :production   # This variable governs all config

class Config

  attr_accessor :keys, :env

  def initialize(env=:production)
    @env = env

    @keys = {
      :production => {
          :debug => false,
          :scheme => "http://",
          :domain => "yobitch.me",
          :user_get => "/user_post.json",
          :user_save => "/api/v1/users",
          :user_post => "/api/v1/users/send_message",
          :message_send => "/api/v1/users/send_message",
          :add_friend => "/api/v1/users/add_friend",
          :sync_contacts => "/api/v1/users/sync_contacts",
          :gcm_sender_id => "77573904884",
          :package_name => "com.rum.yobitch",
          :ad_unit_id => "ca-app-pub-4205525304773174/8192109240",
          :ga_tracking_id => "UA-52998741-1",
          :bugsense_id => "bc7fb570"
        },
        :development => {
          :debug => true,
          :scheme => "http://",
          :domain => "192.168.43.186",
          :user_get => "/user_post.json",
          :user_save => "/user_post.json",
          :user_post => "/api/v1/users/send_message",
          :message_send => "/api/v1/users/send_message",
          :add_friend => "/api/v1/users/add_friend",
          :sync_contacts => "/api/v1/users/sync_contacts",
          :gcm_sender_id => "77573904884",
          :package_name => "com.rum.yobitch",
          :ad_unit_id => "ca-app-pub-4205525304773174/8192109240",
          :ga_tracking_id => "UA-52998741-1",
          :bugsense_id => "bc7fb570"
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
