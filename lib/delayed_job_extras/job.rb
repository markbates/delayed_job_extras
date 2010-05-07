module Delayed
  class Job < ActiveRecord::Base
    
    def reset!
      self.run_at = Time.now
      self.attempts = 0
      self.last_error = nil
      self.save!
      self.reload
    end
    
    def deserialize_with_extras(source)
      begin
        source.scan(/!ruby\/object:(\S+)\s/).flatten.each do |x| 
          x.strip!
          x.to_s.constantize
        end
      rescue Exception => e
        raise e
      end
      deserialize_without_extras(source)
    end
    
    alias_method_chain :deserialize, :extras
    
    def invoke_job_with_extras
      begin
        self.payload_object.dj_object = self
        self.touch(:started_at)
        DJ::Worker.logger.info("Starting #{self.payload_object.class.name}#perform (DJ.id = '#{self.id}')")
        
        invoke_job_without_extras
        
        DJ::Worker.logger.info("Completed #{self.payload_object.class.name}#perform (DJ.id = '#{self.id}') [SUCCESS]")
        self.touch(:finished_at)
      rescue Exception => e
        DJ::Worker.logger.error("Halted #{self.payload_object.class.name}#perform (DJ.id = '#{self.id}') [FAILURE]")
        self.update_attributes(:started_at => nil)
        raise e
      end
      enqueue_again
    end
    
    alias_method_chain :invoke_job, :extras
    
    
    def enqueue_again
      if self.payload_object.re_enqueuable
        new_worker = self.payload_object.clone()
        if self.payload_object.__re_enqueue_block
          self.payload_object.__re_enqueue_block.call(self.payload_object, new_worker)
        end
        new_worker.enqueue
      end
    end
    
    def pending?
      self.started_at.nil? && self.finished_at.nil?
    end
    
    def running?
      !self.started_at.nil? && self.finished_at.nil?
    end
    
    def finished?
      !self.started_at.nil? && !self.finished_at.nil?
    end
    
    class << self
      
      def new_with_worker_class_name(options = {})
        worker_class_name = options[:payload_object].respond_to?(:worker_class_name) ? options[:payload_object].worker_class_name : 'unknown'
        new_without_worker_class_name({:worker_class_name => worker_class_name}.merge(options))
      end
      
      alias_method_chain :new, :worker_class_name
      
    end
    
  end # Job
end # Delayed