module Delayed
  class BaseWorker
    
    if Object.const_defined?(:HoptoadNotifier)
      include HoptoadNotifier::Catcher
    else
      def notify_hoptoad(e)
      end
    end
    
    def task_name
      self.class.to_s.underscore
    end
    
    # Example:
    #   def perform
    #     super do
    #       # some heavy work here
    #     end
    #   end
    def perform
      begin
        yield if block_given?
      rescue Exception => e
        # send to hoptoad!
        notify_hoptoad(e)
        raise e
      end
    end
    
    def logger
      RAILS_DEFAULT_LOGGER
    end

    class << self
      
      # VideoWorker.encode(1) # => Delayed::Job.enqueue(VideoWorker.new(:encode, 1))
      def method_missing(sym, *args)
        self.enqueue(sym, *args)
      end
      
      # VideoWorker.enqueue(1) # => Delayed::Job.enqueue(VideoWorker.new(1))
      def enqueue(*args)
        Delayed::Job.enqueue(self.new(*args))
      end

    end
    
  end # BaseWorker
end # Delayed