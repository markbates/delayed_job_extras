require 'rails_generator'
class DjExtrasGenerator < Rails::Generator::Base
  
  def manifest
    # record do |m|
    #   m.migration_template "migration.rb", 'db/migrate',
    #                        :migration_file_name => "add_delayed_job_extras"
    # end
    record do |m|
      timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
      db_migrate_path = File.join('db', 'migrate')
    
      m.directory(db_migrate_path)
    
      Dir.glob(File.join(File.dirname(__FILE__), 'templates', 'migrations', '*.rb')).sort.each_with_index do |f, i|
        f = File.basename(f)
        f.match(/\d+\_(.+)/)
        timestamp = timestamp.succ
        if Dir.glob(File.join(db_migrate_path, "*_#{$1}")).empty?
          m.file(File.join('migrations', f), 
                 File.join(db_migrate_path, "#{timestamp}_#{$1}"), 
                 {:collision => :skip})
        end
      end
    end
  end
  
end