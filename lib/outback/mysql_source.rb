module Outback
  class MysqlSource < Source
    attr_setter :user, :password, :host, :port, :socket
    
    def databases
      @databases ||= []
    end
    
    def excludes
      @excludes ||= []
    end
    
    def database(*names)
      databases.concat(names.map(&:to_s)).uniq!
    end
    
    def exclude(*names)
      excludes.concat(names.map(&:to_s)).uniq!
    end
    
    def valid?
      user && password
    end
    
    def create_archives(backup_name, timestamp, tmpdir)
      mysql_host = host || 'localhost'
      mysql_port = (port || 3306) unless socket
      if databases.empty?
        #        (host=nil, user=nil, passwd=nil, db=nil, port=nil, socket=nil, flag=nil)
        mysql = Mysql.connect(mysql_host, user, password, nil, mysql_port, socket)
        @databases = mysql.databases - excludes
        mysql.close
      end
      
      archives = databases.collect do |database|
        archive_name = Pathname.new(tmpdir).join("#{backup_name}_#{timestamp}_#{database}.sql.gz")
        mysql_conf_file = Pathname.new(tmpdir).join('outback_my.cnf')
        File.open(mysql_conf_file, 'w') { |f| f << "[client]\npassword=#{password}\n" }
        FileUtils.chmod 0600, mysql_conf_file
        Outback.debug "MysqlSource: dumping database '#{database}'"
        commandline = "mysqldump --defaults-extra-file=#{mysql_conf_file} --opt --user=#{user} --host=#{mysql_host} --port=#{mysql_port} #{database} | gzip > #{archive_name}"
        result = `#{commandline}`.strip
        Outback.debug(result) unless result.blank?
        Outback.info "Archived database #{database}"
        TempArchive.new(archive_name, self).tap { |archive| Outback.debug "dumped #{archive.filename.basename} with #{archive.size} bytes" }
      end
    end
  end
end