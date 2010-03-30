# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{delayed_job_extras}
  s.version = "0.12.0.20100330102756"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["markbates"]
  s.date = %q{2010-03-30}
  s.description = %q{Adds support for Hoptoad and is_paranoid to Delayed::Job. Additionally it also adds 'stats' for your workers, and it even includes a base worker that encapsulates a some common functionality.}
  s.email = %q{mark@markbates.com}
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.files = ["lib/delayed_job_extras/action_mailer.rb", "lib/delayed_job_extras/acts_as_paranoid.rb", "lib/delayed_job_extras/extras.rb", "lib/delayed_job_extras/hoptoad.rb", "lib/delayed_job_extras/job.rb", "lib/delayed_job_extras/performable_method.rb", "lib/delayed_job_extras/worker.rb", "lib/delayed_job_extras.rb", "lib/delayed_job_test_enhancements.rb", "README", "LICENSE", "generators/dj_extras_generator.rb", "generators/templates/migrations/001_add_delayed_job_extras.rb", "generators/templates/migrations/002_add_more_time_columns_to_dj.rb", "generators/templates/migrations/003_add_indexes_to_dj.rb"]
  s.homepage = %q{http://www.markbates.com}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{magrathea}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{delayed_job_extras}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<split_logger>, [">= 0"])
    else
      s.add_dependency(%q<split_logger>, [">= 0"])
    end
  else
    s.add_dependency(%q<split_logger>, [">= 0"])
  end
end
