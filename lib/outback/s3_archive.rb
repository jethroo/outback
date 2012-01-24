module Outback
  class S3Archive < Archive
    def purge!
      Outback.debug "purging S3Archive: #{filename}"
      parent.connect
      AWS::S3::S3Object.delete filename, parent.bucket
    end
  end
end