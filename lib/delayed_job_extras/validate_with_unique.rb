# Rails 2 style validation:
module Delayed
  class Job < ActiveRecord::Base
    def validate_with_unique
      validate_without_unique
      if self.payload_object.respond_to?(:unique?) && self.new_record?
        if self.payload_object.unique?
          if Delayed::Job.count(:all, :conditions => {:worker_class_name => self.worker_class_name, :finished_at => nil}) > 0
            self.errors.add_to_base("Only one #{self.worker_class_name} can be queued at a time!")
          end
        end
      end
    end
  
    alias_method_chain :validate, :unique
  end
end