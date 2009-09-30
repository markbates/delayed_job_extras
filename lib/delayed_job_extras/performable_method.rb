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
        if self.dj_object
          dj_id = self.dj_object.id
          self.dj_object.touch(:started_at)
        end
        begin
          DJ::Worker.logger.info("Starting #{self.class.name}#perform (DJ.id = '#{dj_id}')")
          val = perform_without_hoptoad
          DJ::Worker.logger.info("Completed #{self.class.name}#perform (DJ.id = '#{dj_id}') [SUCCESS]")
          self.dj_object.touch(:finished_at) if self.dj_object
          return val
        rescue Exception => e
          notify_hoptoad(exception_to_data(e).merge(:dj => self.dj_object.inspect))
          DJ::Worker.logger.error("Halted #{self.class.name}#perform (DJ.id = '#{dj_id}') [FAILURE]")
          self.dj_object.update_attributes(:started_at => nil) if self.dj_object
          raise e
        end
      end
    
      alias_method_chain :perform, :hoptoad
    end
    
  end # PerformableMethod
end # Delayed