DEBUG = true
SCHEME = "http://"
#BASE_SERVER = "192.168.43.186"
BASE_SERVER = "yobitch.me"
USER_GET = "/user_post.json"
USER_SAVE = "/api/v1/users"
#USER_SAVE = "/user_post.json"
USER_POST = "/api/v1/users/send_message"

ENV = :production

class Config

  attr_accessor :keys, :env

  def initialize(env=:production)
    @env = env

    @keys = {
      :production => {
          :debug => false,
          :scheme => "http",
          :base => "yobitch.me",
          :user_get => "/user_post.json",
          :user_save => "/api/v1/users",
          :user_post => "/api/v1/users/send_message"
        },
        :development => {
          :debug => true,
          :scheme => "http",
          :base => "192.168.43.186",
          :user_get => "/user_post.json",
          :user_save => "/user_post.json",
          :user_post => "/api/v1/users/send_message"
        }
    }
  end

  def self.get(key)
    return @keys[@env][key]
  end

end