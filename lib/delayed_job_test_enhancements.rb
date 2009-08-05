module Delayed
  class Job
    def self.enqueue(obj, *args)
      puts "perform: #{obj.inspect}, #{args.inspect}"
      obj.perform
    end
  end
end