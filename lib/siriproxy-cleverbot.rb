require 'cora'
require 'siri_objects'
require 'pp'
require 'cleverbot'

#######
# This is a "hello world" style plugin. It simply intercepts the phrase "test siri proxy" and responds
# with a message about the proxy being up and running (along with a couple other core features). This 
# is good base code for other plugins.
# 
# Remember to add other plugins to the "config.yml" file if you create them!
######

class SiriProxy::Plugin::Example < SiriProxy::Plugin
  def initialize(config)
    #if you have custom configuration options, process them here!
    @params = nil
  end

  #get the user's location and display it in the logs
  #filters are still in their early stages. Their interface may be modified
  filter "SetRequestOrigin", direction: :from_iphone do |object|
    puts "[Info - User Location] lat: #{object["properties"]["latitude"]}, long: #{object["properties"]["longitude"]}"
    
    #Note about returns from filters:
    # - Return false to stop the object from being forwarded
    # - Return a Hash to substitute or update the object
    # - Return nil (or anything not a Hash or false) to have the object forwarded (along with any 
    #    modifications made to it)
  end 

  listen_for /clever bot (.*)/i do |text|
    @params = Cleverbot::Client.write text
    say @params['message']
    set_state :cbot
    
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  listen_for /(.*)/i, within_state: :cbot do |text|
    @params = Cleverbot::Client.write text, @params
    say @params['message']

    if (text == "goodbye clever bot")
	set_state nil
    end

    request_completed
  end
  
end
