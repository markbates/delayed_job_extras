# Rails 3 style validation:
class UniqueDJValidator < ActiveModel::Validator
  def validate(record)
    
    if record.payload_object.respond_to?(:unique?) && record.new_record?
      if record.payload_object.unique?
        if Delayed::Job.where(:worker_class_name => 'self.worker_class_name', :finished_at => nil).count > 0
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