Gem::Specification.new do |s|
  s.name          = 'outback'
  s.version       = File.read(File.join(File.dirname(__FILE__), 'VERSION')).strip
  s.date          = '2012-01-12'
  s.summary       = "Ruby Backup Tool"
  s.description   = "A Ruby backup tool"
  s.authors       = ['Matthias Grosser', 'onrooby GmbH']
  s.email         = 'mg@onrooby.com'
  s.files         = Dir['{lib}/**/*.rb', 'bin/*', 'MIT-LICENSE', 'VERSION', 'README']
  s.require_path  = 'lib'
  s.homepage      = 'http://rubygems.org/gems/outback'
  
  s.executables << 'outback'
  
  s.add_dependency 'aws-s3'
  s.add_dependency 'activesupport', '>= 2.1.0'
end
