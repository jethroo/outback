Gem::Specification.new do |s|
  s.name          = 'outback'
  s.version       = File.read(File.join(File.dirname(__FILE__), 'VERSION')).strip
  s.date          = '2012-03-21'
  s.summary       = "Ruby Backup Tool"
  s.description   = "A Ruby backup tool"
  s.authors       = ['Matthias Grosser', 'onrooby GmbH']
  s.email         = 'admin@onrooby.com'
  s.files         = Dir['{lib}/**/*.rb', 'bin/*', 'MIT-LICENSE', 'VERSION', 'README.md', 'CHANGELOG']
  s.require_path  = 'lib'
  s.homepage      = 'http://rubygems.org/gems/outback'
  
  s.executables << 'outback'
  
  s.add_dependency 's3'
  s.add_dependency 'activesupport', '>= 3.0.0'
end
