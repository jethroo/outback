require 'pathname'
require 'fileutils'
require 'tempfile'
require 'tmpdir'

require 'active_support/core_ext'

require 'aws/s3'

require 'outback/vendor/mysql'
require 'outback/vendor/metaclass'
require 'outback/vendor/methodphitamine'

require 'outback/support/returning'
require 'outback/support/attr_setter'
require 'outback/support/configurable'
require 'outback/support/mysql_ext'
require 'outback/support/pathname_ext'
require 'outback/configuration'
require 'outback/configuration_error'
require 'outback/source'
require 'outback/directory_source'
require 'outback/mysql_source'
require 'outback/archive'
require 'outback/temp_archive'
require 'outback/target'
require 'outback/directory_target'
require 'outback/directory_archive'
require 'outback/s3_target'
require 'outback/s3_archive'
require 'outback/backup'

module Outback
  VERSION = Pathname.new(__FILE__).dirname.join('..', 'VERSION').read.strip
  
  class << self
    %w(verbose silent).each do |method|
      attr_accessor method
      alias_method "#{method}?", method
    end
    
    def info(message)
      return if silent?
      puts message
      true
    end
    
    def debug(message)
      return unless verbose?
      return if silent?
      puts message
      true
    end
    
    def error(message, options = nil)
      return if silent?
      puts "Outback error: #{message}"
    end
  end
end
