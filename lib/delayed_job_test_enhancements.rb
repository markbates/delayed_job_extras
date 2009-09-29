module Delayed
  class Job
    
    class << self
      def enqueue_with_work_off(obj, *args)
        enqueue_without_work_off(obj, *args)
        Delayed::Job.work_off
      end
      alias_method_chain :enqueue, :work_off
    end
    
  end
end
