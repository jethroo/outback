module Outback
  class ScpTarget < Target
    
    attr_reader :host, :user, :password
    attr_setter :port, :path, :ttl
    
    def initialize(host, user, password)
      @host, @user, @password = host, user, password
    end
    
    def valid?
      host && user && password
    end
    
    def display_name
      "scp:#{user}@#{host}#{':' + port.to_s if port}:#{path}"
    end
    
    def service(force_reconnect = false)
      @service = nil if force_reconnect
      @service ||= S3::Service.new(:access_key_id => access_key, :secret_access_key => secret_key)
    end
    
    def bucket
      service.buckets.find(bucket_name)
    end
    
    def put(archives)
      size = count = 0
      Net::SSH.start(host, user, ssh_options) do |ssh|
        archives.each do |archive|
          basename = archive.filename.basename.to_s
          upload_filename = path ? File.join(path, basename) : basename
          Outback.debug "ScpTarget: storing #{archive.filename} in scp://#{user}@#{host}#{':' + port.to_s if port}:#{upload_filename}"
          ssh.scp.upload! archive.filename.to_s, upload_filename
        end
        size += archive.size
        count += 1
      end
      Outback.info "Uploaded #{count} archives (#{size} bytes) to #{display_name}"
      count
    end
    
    def list_archives(name)
      entries = bucket.objects.select { |e| e.key.start_with?(prefix.to_s) && e.key[prefix.to_s.size..-1].match(Archive::NAME_PATTERN) }
      entries.map { |e| S3Archive.new(e.key, self) }.select(&its.backup_name == name)
    end
  end
  
  private
  
  def ssh_options
    returning Hash.new do |options|
      options[:password] = password
      options[:port] = port if port
    end
  end
end