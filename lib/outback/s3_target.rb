module Outback
  class S3Target < Target
    attr_setter :bucket_name, :access_key, :secret_key, :ttl, :prefix
    
    def display_name
      "s3:#{bucket_name}/#{prefix}"
    end
    
    def valid?
      bucket_name && access_key && secret_key
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
      archives.each do |archive|
        object_name = [prefix.to_s, archive.filename.basename.to_s].join('/')
        Outback.debug "S3Target: storing #{archive.filename} in s3://#{bucket_name}/#{object_name}"
        object = bucket.objects.build(object_name)
        object.content = archive.open
        object.acl = :private
        object.save
        if object.exists?
          size += archive.size
          count += 1
        else
          Outback.error "S3 archive upload failed: #{object_name}"
        end
      end
      Outback.info "Uploaded #{count} archives (#{size} bytes) to #{display_name}"
      count
    end
    
    def list_archives(name)
      entries = bucket.objects.select { |e| e.key.start_with?(prefix.to_s) && e.key[prefix.to_s.size..-1].match(Archive::NAME_PATTERN) }
      entries.map { |e| S3Archive.new(e.key, self) }.select(&its.backup_name == name)
    end
  end
  
end