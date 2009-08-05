module Delayed
  class PerformableMethod
    
    attr_accessor :worker_class_name
    
    def initialize_with_worker_class_name(object, method, args)
      self.worker_class_name = "#{object.class}__#{method}".underscore
      initialize_without_worker_class_name(object, method, args)
    end
    
    alias_method_chain :initialize, :worker_class_name
    
    if Object.const_defined?(:HoptoadNotifier)
      include HoptoadNotifier::Catcher
      
      def perform_with_hoptoad
        begin
          perform_without_hoptoad
        rescue Exception => e
          notify_hoptoad(e)
          raise e
        end
      end
    
      alias_method_chain :perform, :hoptoad
    end
    
  end # PerformableMethod
end # Delayed