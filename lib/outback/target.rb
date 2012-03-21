module Outback
  class Target
    include Configurable

    def outdated_archives(name)
      list_archives(name).select(&:outdated?)
    end
    
    def purge!(name)
      size = count = 0
      outdated_archives(name).each do |archive|
        archive_size = archive.size
        if archive.purge!
          count += 1
          size += archive_size
        end
      end
      Outback.info "Purged #{count} archives (#{size} bytes) from #{display_name}"
    end
  
  end
end