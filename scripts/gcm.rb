#!/usr/bin/env ruby

require "rubygems"
require "higcm"
require "pp"

config = {
  :gcm_api_key => "AIzaSyCdNZj8zoB25lEz65eqTULCnMj0nPupETo",
  :collapse_key => "com.rum.yobitch"
}

registration_ids = [
  "APA91bGRhJ6pzt8YE7HaMrWSGQsCLjO_YOdNozJfDKZBYVrsoaCJQ-4XNonNccf-tcjkYJBVjjS_fKGNJaV61Yszwokak5PbTecDrJGAWR4jsM4wD9ZWiLcpZoMTV09tb9C8QdvVGAh9Ini98qbfgb2h1Fq1Vcof7Q"
]

messages = [
  {
    "data" => {
      "sender" => {
        "id" => "0",
        "name" => "Bot",
        "email" => "asnafam@gmail.com"
      },
      "receiver" => {
        "id" => "3",
        "name" => "makuchaku",
        "email" => "maku@makuchaku.in"
      },
      "message" => "You are a B*tch",
      "title" => "Ravi Asnani b*tched you!",
      "klass" => "bitch",
      "id" => rand(1000)
    }
  }
  # {
  #   "data" => {
  #     "sender" => {
  #       "id" => "1",
  #       "name" => "Ravi Asnani",
  #       "email" => "asnafam@gmail.com"
  #     },
  #     "receiver" => {
  #       "id" => "3",
  #       "name" => "makuchaku",
  #       "email" => "maku@makuchaku.in"
  #     },
  #     "message" => "Mayank added you as a friend",
  #     "title" => "Let the B*tching begin!",
  #     "klass" => "friend_add",
  #     "id" => rand(1000)
  #   }
  # }

]



# config => config object
# messages => data payload which will be sent to mobile
# registration_ids => Array of string id's
def send_all(config, messages, registration_ids)
  messages.each { |message|
    options = {
      :collapse_key => config[:collapse_key],
      :data         => message
    }    

    sender = HiGCM::Sender.new(config[:gcm_api_key])

    response = sender.send(registration_ids, options)
    
    result = JSON.parse(response.body)["success"] == 1 ? true : false
    puts "Sending messages : #{message[:type]} => #{message[:title]}/#{message[:message]} => " + (result == true ? "[OK]" : "[E!]")
    pp response.body #if result != true
  }
end



puts "Sending all GCM push messages to #{registration_ids}"
send_all(config, messages, registration_ids)
puts "All done"

