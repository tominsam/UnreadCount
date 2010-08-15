require "yaml"

class Unread
  
  
  def initialize
    
    config_file = File.join(File.dirname($0), "config.yaml")
    if !File.exist?(config_file)
      STDERR.puts "config file missing: create #{ config_file }"
      exit(1)
    end
    @config = YAML.load_file(config_file)
  end

  def log(x)
    if self.config?('log')
      STDERR.puts x
    end
  end
  
  def config?(name)
    return !(@config[name].nil? || !@config[name])
  end

  def config(name)
    if @config[name].nil?
      STDERR.puts "config variable '#{name}' not found"
      exit(1)
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
    end
    return @agent

  end
  
  def save_cookies
    @jar.save_as(@cookie_jar)
  end
  
  def agent_get(url)
    # TODO - retry more than once, with back-off or something
    begin
      return self.agent.get(url)
    rescue Exception => e
      # gratuitous
      self.log "get failed (#{e}). sleeping."
      sleep 10
      self.log "retrying."
      return self.agent.get(url)
    end
  end


end
