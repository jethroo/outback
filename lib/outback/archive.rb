module Outback
  class Archive
    NAME_PATTERN = /([A-Za-z0-9.\-]+)_(\d{14})_(\w+)/
    
    attr_reader :filename, :backup_name, :timestamp, :source_name, :parent
    
    def initialize(filename, parent)
      @filename, @parent = Pathname.new(filename), parent
      unless match_data = @filename.basename.to_s.match(NAME_PATTERN)
        raise ArgumentError, 'invalid name'
      end
      @backup_name, @timestamp, @source_name = match_data.captures[0..2]
    end
    
    def size
      filename.size
    end
    
    def open
      filename.open
    end
    
    def outdated?
      if timestamp && parent && parent.ttl
        Time.now - Time.parse(timestamp) > parent.ttl
      end
    end
    
  end
end
