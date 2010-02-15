begin
  # If the is_paranoid gem is available
  # let's use it so we can have a record of the
  # tasks that have been performed.
  if defined?(Caboose::Acts::Paranoid)
  
    DJ::Worker.logger.info "Adding acts_as_paranoid support to Delayed::Job"
  
    begin
      module Delayed
        class Job
          include HoptoadNotifier::Catcher
        
          acts_as_paranoid
        
        end # Job
      end # Delayed
    rescue Exception => e
      DJ::Worker.logger.error(e)
      raise e
    end

    
  end
  
rescue Exception => e
end