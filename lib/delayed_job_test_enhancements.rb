module Delayed
  class Job
    def self.enqueue(obj, *args)
      if obj.respond_to?(:dj_object)
        if obj.dj_object.nil?
          obj.dj_object = Delayed::Job.new
          obj.dj_object.id = 1
        end
      end
      obj.perform
    end
  end
end