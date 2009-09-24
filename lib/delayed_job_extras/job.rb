module Delayed
  class Job < ActiveRecord::Base
    
    if (self.respond_to?(:is_paranoid))
      is_paranoid
    else
      alias_method :count_with_destroyed, :count
      alias_method :find_with_destroyed, :find
    end
    
    def payload_object=(object)
      self.worker_class_name = object.worker_class_name if object.respond_to?(:worker_class_name)
      self['handler'] = object.to_yaml
    end
    
    def invoke_job_with_dj
      payload_object.dj_object = self if payload_object.respond_to?(:dj_object)
      invoke_job_without_dj
    end
    
    alias_method_chain :invoke_job, :dj
    
    class << self
      
      def stats(start_date = 1.day.ago.beginning_of_day, end_date = Time.now.beginning_of_day)
        workers = {}
        Delayed::Job.find_with_destroyed(:all, :select => :worker_class_name, :group => :worker_class_name).each do |dj|
          dj.worker_class_name = 'UNKNOWN' if dj.worker_class_name.blank?
          workers[dj.worker_class_name] = {} 
        end
        workers.each do |worker, stats|
          wname = (worker == 'UNKNOWN' ? nil : worker)
          stats[:total] = Delayed::Job.count_with_destroyed(:conditions => {:worker_class_name => wname})
          stats[:remaining] = Delayed::Job.count(:conditions => {:worker_class_name => wname})
          stats[:processed] = stats[:total] - stats[:remaining]
          stats[:failures] = Delayed::Job.count(:conditions => ['worker_class_name = ? and attempts > 1', wname])
          if start_date
            date_stats = {:start_date => start_date, :end_date => end_date}
            date_stats[:total] = Delayed::Job.count_with_destroyed(:conditions => ['worker_class_name = ? and (created_at > ? and created_at < ?)', wname, start_date, end_date])
            date_stats[:remaining] = Delayed::Job.count(:conditions => ['worker_class_name = ? and (created_at > ? and created_at < ?)', wname, start_date, end_date])
            date_stats[:processed] = date_stats[:total] - date_stats[:remaining]
            date_stats[:failures] = Delayed::Job.count(:conditions => ['worker_class_name = ? and attempts > 1 and (created_at > ? and created_at < ?)', wname, start_date, end_date])
            stats[:date_range] = date_stats
          end
          workers[worker] = stats
        end
        workers
      end
      
    end
    
  end # Job
end # Delayed