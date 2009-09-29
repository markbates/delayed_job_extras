module Delayed
  class Job
    
    def self.enqueue(obj, *args)
      if obj.respond_to?(:dj_object)
        if obj.dj_object.nil?
          obj.dj_object = Delayed::Job.new
        end
      end
      obj.perform
      obj.respond_to?(:dj_object) ? obj.dj_object : nil
    end
    
  end
end