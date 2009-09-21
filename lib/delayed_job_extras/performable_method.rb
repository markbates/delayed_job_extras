module Delayed
  class PerformableMethod
    
    attr_accessor :worker_class_name
    attr_accessor :dj_object
    
    def initialize_with_worker_class_name(object, method, args)
      self.worker_class_name = "#{object.class}__#{method}".underscore
      initialize_without_worker_class_name(object, method, args)
    end
    
    alias_method_chain :initialize, :worker_class_name
    
    if Object.const_defined?(:HoptoadNotifier)
      include HoptoadNotifier::Catcher
      
      def perform_with_hoptoad
        dj_id = 'unknown'
        dj_id = self.dj_object.id if self.dj_object
        begin
          Delayed::Worker.logger.info("Starting #{self.class.name}#perform (DJ.id = '#{dj_id}')")
          perform_without_hoptoad
          Delayed::Worker.logger.info("Completed #{self.class.name}#perform (DJ.id = '#{dj_id}') [SUCCESS]")
        rescue Exception => e
          notify_hoptoad(e)
          Delayed::Worker.logger.info("Halted #{self.class.name}#perform (DJ.id = '#{dj_id}') [FAILURE]")
          raise e
        end
      end
    
      alias_method_chain :perform, :hoptoad
    end
    
  end # PerformableMethod
end # Delayed