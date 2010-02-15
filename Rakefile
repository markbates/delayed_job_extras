require 'rubygems'
require 'gemstub'

Gemstub.test_framework = :rspec

Gemstub.gem_spec do |s|
  s.email = 'mark@markbates.com'
  s.homepage = 'http://www.markbates.com'
  # s.name = 'markbates-delayed_job_extras'
  s.description = %{Adds support for Hoptoad and is_paranoid to Delayed::Job. Additionally it also adds 'stats' for your workers, and it even includes a base worker that encapsulates a some common functionality.}
  s.version = "0.11.1"
  s.rubyforge_project = "magrathea"
  s.add_dependency('markbates-split_logger')
  s.files = FileList['lib/**/*.*', 'README', 'LICENSE', 'bin/**/*.*', 'generators/**/*.*']
end

Gemstub.rdoc do |rd|
  rd.title = "Delayed::Job Extras"
end
