module Delayed
  class Worker
    
    PRIORITY_LEVELS = {:immediate => 10000, :high => 1000, :medium => 500, :normal => 0, :low => -100, :who_cares => -1000}
    
    attr_accessor :dj_object
    
    def priority=(x)
      @priority = x
    end
    
    def priority
      return @priority ||= 0
    end
    
    if Object.const_defined?(:HoptoadNotifier)
      include HoptoadNotifier::Catcher
    else
      def notify_hoptoad(e)
        logger.error(e)
      end
    end
    
    def worker_class_name
      self.class.to_s.underscore
    end
    
    def logger
      RAILS_DEFAULT_LOGGER
    end
    
    def enqueue(options = {})
      options = {:priority => self.priority}.merge(options)
      Delayed::Job.enqueue(self, options)
    end

    class << self
      
      def priority(level = 0)
        define_method('priority') do
          if level.is_a?(Symbol)
            level = Delayed::Worker::PRIORITY_LEVELS[level] ||= 0
          end
          return @priority ||= level
        end
      end
      
      # VideoWorker.encode(1) # => Delayed::Job.enqueue(VideoWorker.new(:encode, 1))
      def method_missing(sym, *args)
        self.enqueue(sym, *args)
      end
      
      # VideoWorker.enqueue(1) # => Delayed::Job.enqueue(VideoWorker.new(1))
      def enqueue(*args)
        self.new(*args).enqueue
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