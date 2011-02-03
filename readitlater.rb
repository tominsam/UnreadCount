#!/usr/bin/env ruby
require 'unread.rb'
require 'json'

$unread = Unread.new

$unread.log "getting list"

def get(path)
    return $unread.agent_get(path,
        :apikey => $unread.config("readitlater_apikey"),
        :username => $unread.config("readitlater_username"),
        :password => $unread.config("readitlater_password")
    )
end

list = get("https://readitlaterlist.com/v2/stats")

json = JSON.parse( list.body )

total = json["count_unread"]

if $unread.config?("readitlater_output")
  File.open($unread.config("readitlater_output"), "a") {|f| f.puts total }
else
  puts total
end


