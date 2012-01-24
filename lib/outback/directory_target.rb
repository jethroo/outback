module Outback
  class DirectoryTarget < Target
    attr_reader :path
    attr_setter :user, :group, :directory_permissions, :archive_permissions, :ttl, :move
    
    def initialize(path)
      @path = Pathname.new(path)
    end
    
    def valid?
      (user and group) or (not user and not group)
    end
    
    def put(archives)
      Dir.mkdir(path) unless path.directory?
      FileUtils.chmod directory_permissions || 0700, path
      size = 0
      archives.each do |archive|
        basename = Pathname.new(archive.filename).basename
        if move
          Outback.debug "moving #{archive.filename} to #{path}"
          FileUtils.mv archive.filename, path
        else
          Outback.debug "copying #{archive.filename} to #{path}"
          FileUtils.cp_r archive.filename, path
        end
        archived_file = path.join(basename)
        Outback.debug "setting permissions for #{archived_file}"
        FileUtils.chmod archive_permissions || 0600, archived_file
        if user && group
          Outback.debug "setting owner #{user}, group #{group} for #{archived_file}"
          FileUtils.chown user, group, archived_file
        end
        size += archived_file.size
      end
      Outback.debug "#{move ? 'Moved' : 'Copied'} #{archives.size} archives (#{size} bytes) to directory #{path}"
    end

    def list_archives(name)
      path.files(Archive::NAME_PATTERN).map { |f| DirectoryArchive.new(f, self) }.select(&its.backup_name == name)
    end
    
  end
end