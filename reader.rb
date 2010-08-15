#!/usr/bin/env ruby
require 'unread.rb'
require 'json'

unread = Unread.new

# all based on http://code.google.com/p/pyrfeed/wiki/GoogleReaderAPI which might be nonsense


auth_token = nil
auth_file = File.join(File.dirname($0), "reader_auth.txt")

if File.exist? auth_file
  auth_token = File.open(auth_file) {|f| f.read.strip }
  unread.agent_add_header("Authorization", "GoogleLogin auth=#{auth_token}")

  begin
    unread.log("getting unread count")
    json = unread.agent_get("http://www.google.com/reader/api/0/unread-count?output=json")
  rescue Mechanize::ResponseCodeError => e
    if e.response_code != '401'
      raise
    end
  end
end

# we didnt even bother trying if there wasn't an auth_file
if json.nil?

  unread.log("not authorized")
  
  login = unread.agent_post("https://www.google.com/accounts/ClientLogin",
    :service => "reader",
    :Email => unread.config("reader_username"),
    :Passwd => unread.config("reader_password"),
    :source => "UnreadCount <http://github.com/tominsam/UnreadCount>",
    :continue => 'http://www.google.com/'
  )
  
  result = Hash[*( login.body.split(/\n/).map{|line| line.split(/=/) }.flatten )]
  sid = result["SID"]
  auth = result["Auth"]

  if sid.nil? || auth.nil?
    STDERR.puts "Failed to log in for some reason"
    exit(1)
  end
  
  uri = URI.parse("http://www.google.com/")
  cookie = Mechanize::Cookie.new( "SID", sid )
  cookie.domain = ".google.com"
  cookie.path = "/"
  cookie.expires = Time.parse("2020-01-01").to_s
  unread.agent.cookie_jar.add( uri, cookie )
  
  unread.agent_add_header("Authorization", "GoogleLogin auth=#{auth}")

  unread.log("getting unread count")
  json = unread.agent_get("http://www.google.com/reader/api/0/unread-count?output=json")
  
  # save cookies and auth _after_ the request works..
  unread.save_cookies
  File.open(auth_file, "w") {|f| f.puts auth }
end

json = JSON.parse( json.body )
#pp json

total = 0

for folder in json["unreadcounts"]
  if folder['id'] and folder['id'].match(/^feed/)
    total += folder['count'].to_i
  end
end

unread.log("found #{ total } unread items")

if unread.config?("reader_output")
  File.open(unread.config("reader_output"), "a") {|f| f.puts total }
else
  puts total
end
