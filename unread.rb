require 'rubygems'
require "yaml"
require "uri"

gem 'mechanize', "~> 1.0.0"
require 'mechanize'

class Unread
  
  
  def initialize
    
    config_file = File.join(File.dirname($0), "config.yaml")
    if !File.exist?(config_file)
      STDERR.puts "config file missing: create #{ config_file }"
      exit(1)
    end
    @config = YAML.load_file(config_file)

    @agent_headers = {}
  end

  def log(x)
    if self.config?('log')
      STDERR.puts x
    end
  end
  
  def config?(name)
    return !(@config[name].nil? || !@config[name])
  end

  def config(name, default = nil)
    if @config[name].nil?
      if default.nil?
        STDERR.puts "config variable '#{name}' not found"
        exit(1)
      else
        return default
      end
    end
    return @config[name]
  end


  def agent
    if @agent.nil?
      # load cookies from disk if they're there
      @cookie_jar = File.join(File.dirname($0), "cookiejar.txt")
      @jar = Mechanize::CookieJar.new
      if File.exist?(@cookie_jar)
        self.log "loading cookies from #{@cookie_jar}"
        @jar.load(@cookie_jar);
      end

      @agent = Mechanize.new
      @agent.cookie_jar = @jar
      # http://stackoverflow.com/questions/1327495/ruby-mechanize-post-with-header
      @agent.pre_connect_hooks << lambda { |p|
        for k,v in @agent_headers
          p[:request][k] = v
        end
      }
    end
    return @agent

  end

  def agent_add_header(k,v)
    @agent_headers[k] = v
  end
  
  def save_cookies
    @jar.save_as(@cookie_jar)
  end
  
  def agent_get(url, data = {})
    # TODO - retry more than once, with back-off or something
    if data and data.keys.size > 0
        url += "?"
        for k,v in data
            url += "&#{URI.escape k.to_s}=#{URI.escape v.to_s}"
        end
    end
    begin
      return self.agent.get(url)
    rescue Exception => e
      if e.respond_to?(:response_code) && e.response_code.match(/^4/)
        raise
      end
      self.log "get failed (#{e}). sleeping."
      sleep 10
      self.log "retrying."
      return self.agent.get(url)
    end
  end
  
  def agent_post( url, data )
    return self.agent.post(url, data )
  end


end
