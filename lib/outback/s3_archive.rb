module Outback
  class S3Archive < Archive
    def size
      object.size.to_i
    end
    
    def purge!
      Outback.debug "purging S3Archive: #{filename}"
      object && object.destroy or Outback.error("could not find object #{filename} for purging")
    end
    
    private
    
    def object
      parent.bucket.objects.find(filename.to_s)
    end
  end
end