module Delayed
  class Job
    
    if (self.respond_to?(:is_paranoid))
      is_paranoid
    else
      alias_method :count_with_destroyed, :count
      alias_method :find_with_destroyed, :find
    end
    
    def payload_object=(object)
      self.worker_name = object.worker_name if object.respond_to?(:worker_name)
      self['handler'] = object.to_yaml
    end
    
    class << self
      
      def stats
        workers = {}
        Delayed::Job.find_with_destroyed(:all, :select => :worker_name, :group => :worker_name).each do |dj|
          dj.worker_name = 'UNKNOWN' if dj.worker_name.blank?
          workers[dj.worker_name] = {} 
        end
        workers.each do |worker, stats|
          wname = (worker == 'UNKNOWN' ? nil : worker)
          stats[:total] = Delayed::Job.count_with_destroyed(:conditions => {:worker_name => wname})
          stats[:remaining] = Delayed::Job.count(:conditions => {:worker_name => wname})
          stats[:processed] = stats[:total] - stats[:remaining]
          stats[:failures] = Delayed::Job.count(:conditions => ['worker_name = ? and attempts > 1', wname])
          workers[worker] = stats
        end
        workers
      end
      
    end
    
  end # Job
end # Delayed