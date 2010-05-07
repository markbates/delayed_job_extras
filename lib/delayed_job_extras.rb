require 'split_logger'

def ruby19?
  RUBY_VERSION.match(/^1\.9\.\d+$/)
end

path = File.join(File.dirname(__FILE__), 'delayed_job_extras')
require File.join(path, 'extras')
require File.join(path, 'job')
require File.join(path, 'performable_method')
require File.join(path, 'worker')
require File.join(path, 'action_mailer')

require File.join(path, 'hoptoad')
# require File.join(path, 'acts_as_paranoid')

if Rails.version.match(/^2/)
  require File.join(path, 'validate_with_unique')
else
  require File.join(path, 'unique_dj_validator')
end