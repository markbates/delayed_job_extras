module Delayed
  class Worker
    
    PRIORITY_LEVELS = {:immediate => 10000, :high => 1000, :medium => 500, :normal => 0, :low => -100, :who_cares => -1000}
    
    attr_accessor :dj_object
    attr_accessor :logger
    
    def priority=(x)
      @priority = x
    end
    
    def priority
      return @priority ||= 0
    end
    
    def run_at=(x)
      @run_at = x
    end
    
    def run_at
      return @run_at ||= Time.now
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
      @logger || Delayed::Worker.logger
    end
    
    def enqueue(priority = self.priority, run_at = self.run_at)
      Delayed::Job.enqueue(self, priority, run_at)
    end

    class << self
      
      @@logger = SplitLogger.new
      
      def logger
        @@logger
      end
      
      def logger=(logger)
        @@logger = logger
      end
      
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
          dj_id = 'unknown'
          dj_id = self.dj_object.id if self.dj_object
          begin
            self.logger.info("Starting #{self.class.name}#perform (DJ.id = '#{dj_id}')")
            val = self.instance_eval(&block)
            self.logger.info("Completed #{self.class.name}#perform (DJ.id = '#{dj_id}') [SUCCESS]")
            return val
          rescue Exception => e
            # send to hoptoad!
            notify_hoptoad(e)
            self.logger.info("Halted #{self.class.name}#perform (DJ.id = '#{dj_id}') [FAILURE]")
            raise e
          end
        end
      end

    end
    
  end # Worker
end # Delayed