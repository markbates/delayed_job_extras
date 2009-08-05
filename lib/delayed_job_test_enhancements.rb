module Delayed
  class Job
    def self.enqueue(obj, *args)
      obj.perform
    end
  end
end