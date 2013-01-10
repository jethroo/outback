module Outback
  class Backup
    attr_reader :configuration, :name, :timestamp, :archives, :tmpdir
    delegate :sources, :targets, :to => :configuration
    
    def initialize(configuration)
      raise ArgumentError, "configuration required" unless configuration.is_a?(Outback::Configuration)
      @configuration = configuration
      @name = configuration.name
      @timestamp = Time.now.to_formatted_s(:number)
    end
    
    def run!
      @archives  = []
      begin
        Outback.info "Using working directory #{configuration.tmpdir}" if configuration.tmpdir
        @tmpdir = Dir.mktmpdir([name, timestamp], configuration.tmpdir)
        @archives = create_archives
        Outback.info "Created #{@archives.size} archives"
        store_archives
      ensure
        FileUtils.remove_entry_secure(tmpdir)
      end
      purge_targets
    end
    
    private
    
    def create_archives
      archives = sources.collect do |source|
        source.create_archives(name, timestamp, tmpdir)
      end
      archives.flatten.compact
    end
    
    def store_archives
      targets.each { |target| target.put(archives) }
    end

    def purge_targets
      targets.each { |target| target.purge!(name) }
    end
    
  end
end
