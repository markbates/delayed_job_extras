require 'rubygems'
require 'gemstub'

Gemstub.test_framework = :rspec

Gemstub.gem_spec do |s|
  s.description = %{Adds support for Hoptoad and is_paranoid to Delayed::Job. Additionally it also adds 'stats' for your workers, and it even includes a base worker that encapsulates a some common functionality.}
  s.version = "0.1.6"
  s.rubyforge_project = "magrathea"
  s.files = FileList['lib/**/*.*', 'README', 'LICENSE', 'bin/**/*.*', 'generators/**/*.*']
end

Gemstub.rdoc do |rd|
  rd.title = "Delayed::Job Extras"
end
