#!/usr/bin/env ruby
require 'rubygems'
require 'net/imap'

require 'unread.rb'

unread = Unread.new

unread.log "getting inbox"

imap = Net::IMAP.new(unread.config("imap_server"), unread.config("imap_port", 143), unread.config?("imap_ssl"))

imap.login(unread.config("imap_username"), unread.config("imap_password"))
imap.examine('INBOX')

total = 0

if unread.config("imap_unread_only")
  total += imap.search(["NOT", "SEEN"]).length
else
  total += imap.search(["NOT", "DELETED"]).length
end

imap.disconnect

unread.log "total #{ total }"

if unread.config?("imap_output")
  File.open(unread.config("imap_output"), "a") {|f| f.puts total }
else
  puts total
end


