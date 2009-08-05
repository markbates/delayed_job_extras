# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{delayed_job_extras}
  s.version = "0.1.0.20090805134733"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["markbates"]
  s.date = %q{2009-08-05}
  s.description = %q{Adds support for Hoptoad and is_paranoid to Delayed::Job. Additionally it also adds 'stats' for your workers, and it even includes a base worker that encapsulates a some common functionality.}
  s.email = %q{}
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.files = ["lib/delayed_job_extras/job.rb", "lib/delayed_job_extras/performable_method.rb", "lib/delayed_job_extras/worker.rb", "lib/delayed_job_extras.rb", "lib/delayed_job_test_enhancements.rb", "README", "LICENSE", "generators/dj_extras_generator.rb", "generators/templates/migration.rb"]
  s.homepage = %q{}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{magrathea}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{delayed_job_extras}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
