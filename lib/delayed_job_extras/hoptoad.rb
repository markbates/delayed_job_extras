begin
  # If the hoptoad_notifier gem is available
  # let's use it so we can get some good notifications
  # when an exception is raised.
  require 'hoptoad_notifier'
  
  DJ::Worker.logger.info "Adding Hoptoad support to Delayed::Job"
  
  module Delayed
    class Job
      include HoptoadNotifier::Catcher
      
      def invoke_job_with_hoptoad
        begin
          invoke_job_without_hoptoad
        rescue Exception => e
          notify_hoptoad(exception_to_data(e).merge(:dj => self.inspect))
          raise e
        end
      end
      
      alias_method_chain :invoke_job, :hoptoad
      
    end # Job
  end # Delayed
  
rescue Exception => e
end