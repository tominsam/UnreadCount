#!/usr/bin/env ruby
require 'rubygems'
gem 'mechanize', "~> 1.0.0"
require 'mechanize'
require "yaml"

config_file = File.join(File.dirname($0), "config.yaml")
if !File.exist?(config_file)
  STDERR.puts "config file missing: create #{ config_file }"
  exit(1)
end
$config = YAML.load_file(config_file)

def log(x)
  if $config['log']
    STDERR.puts x
  end
end

# load cookies from disk if they're there
cookie_jar = File.join(File.dirname($0), "cookiejar.txt")
jar = Mechanize::CookieJar.new
if File.exist?(cookie_jar)
  log "loading cookies from #{cookie_jar}"
  jar.load(cookie_jar);
end

agent = Mechanize.new
agent.cookie_jar = jar

log "getting home"
home = agent.get("http://instapaper.com/u")

if not home.uri.to_s.match(/\/u$/)
  # if we get redirected from /u, then we're not logged in.
  log "Not logged in"
  login = agent.get("http://www.instapaper.com/user/login")
  form = login.forms[0]
  form.username = $config['username']
  form.password = $config['password']
  login = agent.submit(form)

  home = agent.get("http://instapaper.com/u")
  if not home.uri.to_s.match(/\/u$/)
    log "login failed"
    exit(1)
  end
  
  jar.save_as(cookie_jar)
  
end

unread = 0


def count(page)
  unread = page.search("#bookmark_list")[0].search("div.tableViewCell").length
  log "  found #{unread} unread"
  return unread
end

unread += count(home)

folders = home.search("#folders a")
for f in folders
  if $config['include_folders'].include? f.text.downcase
    url = f.attr("href")
    if url.match(/\S/)
      log "fetching folder #{f.text} from #{url}"
      folder = agent.get(url)
      unread += count(folder)
    end
  end
end

log "total #{ unread }"

if $config["output"]
  File.open($config["output"], "a") {|f| f.puts unread }
else
  puts unread
end


