#!/usr/bin/env ruby

require "rubygems"
require "higcm"
require "pp"

config = {
  :gcm_api_key => "AIzaSyCdNZj8zoB25lEz65eqTULCnMj0nPupETo",
  :collapse_key => "com.rom.yobitch"
}

registration_ids = [
  "APA91bGLQmyAYTbROYHyKWqv6XVdRY4dNbDAsIRY4ulmDO_tOEbGoJcqsYGq8S1d7-vWcNjKTzC-Wiat3M-Jxt0l8NQSPnldDz0M1o-lZVwMnpmB_mB1V1MrZ93PiTjE3mjJ6s9lJYpCVwdlv4v7iH7FVTEpRdR_mA",
  "APA91bHIWEpiMZ4XD3oLL8Xn6P7FtqRqC7JkuXdCVG5x9ZMPKyGiwks016SCKWvC9Oay0iXDV6i2481sLTsfu3eGpexOKvsIaL47nubpF-v27TdwdSxOdgX2MWUsSURQZh4-N780j6-YTkavDubXwdAEqP5lMLlopA"
]

messages = [
  {
   "data" => {
      "sender" => {
        "id" => "1",
        "name" => "Ravi Asnani",
        "email" => "asnafam@gmail.com"
      },
    "receiver" => {
      "id" => "3",
      "name" => "makuchaku",
      "email" => "maku@makuchaku.in"
    },
    "message" => "You are a B*tch",
    "title" => "Ravi Asnani b*tched you!"
   }
  }
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

