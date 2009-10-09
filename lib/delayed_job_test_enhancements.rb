unless defined?(DELAYED_JOB_TEST_ENHANCEMENTS)
  
  module Delayed
    class Job
    
      class << self
        def enqueue_with_work_off(obj, *args)
          job = enqueue_without_work_off(obj, *args)
          job.invoke_job
          return job
        end
        alias_method_chain :enqueue, :work_off
      end
    
    end # Job
  end # Delayed
  
  DELAYED_JOB_TEST_ENHANCEMENTS = 1
end # unless defined?('DELAYED_JOB_TEST_ENHANCEMENTS')