# Rails 3 style validation:
class UniqueDJValidator < ActiveModel::Validator
  def validate()
    
    if record.payload_object.respond_to?(:unique?) && record.new_record?
      if record.payload_object.unique?
        if Delayed::Job.count(:all, :conditions => {:worker_class_name => record.worker_class_name, :finished_at => nil}) > 0
          record.errors.add_to_base("Only one #{record.worker_class_name} can be queued at a time!")
        end
      end
    end
  end
end

module Delayed
  class Job < ActiveRecord::Base
    validates_with UniqueDJValidator
  end
end