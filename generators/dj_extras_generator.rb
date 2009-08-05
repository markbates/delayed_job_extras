class DjExtrasGenerator < Rails::Generator::Base
  
  def manifest
    record do |m|
      m.migration_template "migration.rb", 'db/migrate',
                           :migration_file_name => "add_delayed_job_extras"
    end
  end
  
end