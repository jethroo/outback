module Outback
  class DirectoryArchive < Archive
    def purge!
      Outback.debug "purging DirectoryArchive: #{filename}"
      filename.unlink
    end
  end
end