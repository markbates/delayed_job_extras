module Delayed
  class Worker
    
    if Object.const_defined?(:HoptoadNotifier)
      include HoptoadNotifier::Catcher
    else
      def notify_hoptoad(e)
      end
    end
    
    def worker_name
      self.class.to_s.underscore
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
      
      def perform(&block)
        define_method(:perform) do
          begin
            self.instance_eval(&block)
          rescue Exception => e
            # send to hoptoad!
            notify_hoptoad(e)
            raise e
          end
        end
      end

    end
    
  end # Worker
end # Delayed