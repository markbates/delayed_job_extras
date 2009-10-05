begin
  # If the is_paranoid gem is available
  # let's use it so we can have a record of the
  # tasks that have been performed.
  require 'is_paranoid'
  
  DJ::Worker.logger.info "Adding is_paranoid support to Delayed::Job"
  
  module Delayed
    class Job
      include HoptoadNotifier::Catcher
      
      is_paranoid
      
    end # Job
  end # Delayed
  
rescue Exception => e
end