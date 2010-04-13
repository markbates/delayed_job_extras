begin

  DJ::Worker.logger.info "Adding Hoptoad support to Delayed::Job"
  
  begin
    module Delayed
      class Job
        
        def invoke_job_with_hoptoad
          if defined?(HoptoadNotifier)
            Delayed::Job.send(:define_method, :invoke_job_with_hoptoad) do
              begin
                invoke_job_without_hoptoad
              rescue Exception => e
                HoptoadNotifier.notify_or_ignore(e, :cgi_data => self.attributes)
                raise e
              end
            end
          else
            Delayed::Job.send(:define_method, :invoke_job_with_hoptoad) do
              invoke_job_without_hoptoad
            end
          end
          invoke_job_with_hoptoad
        end
        
        alias_method_chain :invoke_job, :hoptoad
        
      end # Job
    end # Delayed
  rescue Exception => e
    DJ::Worker.logger.error(e)
    raise e
  end

  
rescue Exception => e
end