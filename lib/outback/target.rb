module Outback
  class Target
    include Configurable

    def outdated_archives(name)
      list_archives(name).select(&:outdated?)
    end
    
    def purge!(name)
      outdated_archives(name).each &:purge!
    end
  
  end
end