module Delayed
  class Job
    module Extras
      
      PRIORITY_LEVELS = {:immediate => 10000, :high => 1000, :medium => 500, :normal => 0, :low => -100, :who_cares => -1000}
      
      def self.included(klass)
        klass.send(:include, Delayed::Job::Extras::InstanceMethods)
        klass.extend(Delayed::Job::Extras::ClassMethods)
        klass.class_eval do
          class << self
            def new_with_extras(*args)
              klass = new_without_extras(*args)
              klass.__original_args = args
              return klass
            end

            alias_method_chain :new, :extras
          end
        end
      end
      
      module InstanceMethods
        
        attr_accessor :dj_object
        attr_accessor :run_at
        attr_accessor :priority
        attr_accessor :logger
        attr_accessor :worker_class_name
        attr_accessor :__original_args
        attr_accessor :__re_enqueue_block
        attr_accessor :re_enqueuable

        def priority
          case @priority
          when Symbol
            Delayed::Job::Extras::PRIORITY_LEVELS[@priority] ||= 0
          when Fixnum
            @priority
          else
            0
          end
        end

        def run_at
          return @run_at ||= Time.now
        end

        def logger
          @logger ||= self.class.logger
        end
        
        def worker_class_name
          @worker_class_name ||= self.class.to_s.underscore
        end
        
        def enqueue(priority = self.priority, run_at = self.run_at)
          Delayed::Job.enqueue(self, priority, run_at)
        end
        
        alias_method :save, :enqueue
        
        def unique?
          false
        end
        
      end # InstanceMethods
      
      module ClassMethods
        
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
              level = Delayed::Job::Extras::PRIORITY_LEVELS[level] ||= 0
            end
            return @priority ||= level
          end
        end
        
        def enqueue(*args)
          self.new(*args).enqueue
        end
        
        def re_enqueue(&block)
          define_method('re_enqueuable') do
            true
          end
          define_method('__re_enqueue_block') do
            block
          end
        end
        
      end # ClassMethods
      
    end # Extras
  end # Job
end # Delayed