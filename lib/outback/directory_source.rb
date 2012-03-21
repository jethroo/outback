module Outback
  class DirectorySource < Source
    attr_reader :path
    
    def initialize(path)
      @path = path
    end
    
    def source_name
      path.gsub(/[^A-Za-z0-9\-_.]/, '_').gsub(/(\A_|_\z)/, '')
    end
    
    def excludes
      @excludes ||= []
    end
    
    def exclude(*paths)
      excludes.concat(paths.map(&:to_s)).uniq!
    end
    
    def create_archives(backup_name, timestamp, tmpdir)
      source_dir = Pathname.new(path).realpath
      archive_name = Pathname.new(tmpdir).join("#{backup_name}_#{timestamp}_#{source_name}.tar.gz")
      exclude_list = Pathname.new(tmpdir).join('exclude_list.txt')
      File.open(exclude_list, 'w') { |f| f << excludes.join("\n") }
      commandline = "tar --create --file #{archive_name} --preserve-permissions --gzip --exclude-from #{exclude_list} --directory / #{source_dir.to_s.sub(/\A\//, '')}"
      Outback.debug "executing command: #{commandline}"
      result = `#{commandline}`
      Outback.debug "result: #{result}"
      Outback.info "Archived directory #{path}"
      [TempArchive.new(archive_name, self)]
    end
  end
end