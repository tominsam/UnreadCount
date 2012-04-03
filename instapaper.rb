#!/usr/bin/env ruby
require 'unread.rb'

unread = Unread.new

unread.log "getting /u.."
home = unread.agent_get("http://instapaper.com/u")


if not home.uri.to_s.match(/\/u$/)
  # if we get redirected from /u, then we're not logged in.
  unread.log "logging in.."
  login = unread.agent_get("http://www.instapaper.com/user/login")
  form = login.forms[0]
  form.username = unread.config('instapaper_username')
  form.password = unread.config('instapaper_password')
  login = unread.agent.submit(form)

  home = unread.agent_get("http://instapaper.com/u")
  if not home.uri.to_s.match(/\/u$/)
    STDERR.puts "login failed"
    exit(1)
  end
  
  unread.save_cookies
  
end

total = 0

def count(unread, page)
  found = page.search("#bookmark_list")[0].search("div.tableViewCell").length
  unread.log "  found #{found} unread"

  if page.search("//a[span='Older items']").first
    return found + count(unread, unread.agent_get(page.search("//a[span='Older items']").first.attr('href')))
  else
    return found
  end
end

total += count(unread, home)

folders = home.search("#folders a")
for f in folders
  if unread.config('instapaper_folders').include? f.text.downcase
    url = f.attr("href")
    if url.match(/\S/)
      unread.log "fetching folder #{f.text} from #{url}.."
      folder = unread.agent_get(url)
      total += count(unread, folder)
    end
  end
end

unread.log "total #{ total }"

if unread.config?("instapaper_output")
  File.open(unread.config("instapaper_output"), "a") {|f| f.puts total }
else
  puts total
end


