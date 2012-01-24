module Outback
  class S3Target < Target
    attr_setter :bucket, :access_key, :secret_key, :ttl, :prefix
    
    def valid?
      bucket && access_key && secret_key
    end
    
    def connect(force = true)
      @connection = nil if force
      @connection ||= AWS::S3::Base.establish_connection!(:access_key_id => access_key, :secret_access_key => secret_key)
    end
    
    def put(archives)
      connect
      archives.each do |archive|
        object_name = [prefix.to_s, archive.filename.basename.to_s].join('/')
        Outback.debug "S3Target: storing #{archive.filename} in s3://#{bucket}/#{object_name}"
        AWS::S3::S3Object.store object_name, archive.open, bucket
        object_exists = AWS::S3::S3Object.exists?(object_name, bucket)
        Outback.debug "Checking if object exists: #{object_exists}"
      end
      Outback.debug "Uploaded #{archives.sum(&:size)} bytes to S3"
    end
    
    def list_archives(name)
      connect
      entries = AWS::S3::Bucket.objects(bucket).select { |e| e.key.start_with?(prefix.to_s) && e.key[prefix.to_s.size..-1].match(Archive::NAME_PATTERN) }
      entries.map { |e| S3Archive.new(e.key, self) }.select(&its.backup_name == name)
    end
  end
  
end