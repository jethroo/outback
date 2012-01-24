module Outback
  class Source
    include Configurable
    
    def create_archive(backup_name, timestamp, tmpdir)
      # implement in subclasses
    end
    
  end
end