begin
  # If the hoptoad_notifier gem is available
  # let's use it so we can get some good notifications
  # when an exception is raised.
  require 'hoptoad_notifier'
rescue Exception => e
end

begin
  # If the is_paranoid gem is available
  # let's use it so we can have a record of the
  # tasks that have been performed.
  require 'is_paranoid'
rescue Exception => e
end

require 'split_logger'

Dir.glob(File.join(File.dirname(__FILE__), 'delayed_job_extras', '**/*.rb')).each do |f|
  require File.expand_path(f)
end
