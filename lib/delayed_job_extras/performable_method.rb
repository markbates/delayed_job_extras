module Delayed
  class PerformableMethod
    include Delayed::Job::Extras
    
    attr_accessor :worker_class_name
    
    def initialize_with_extras(object, method, args)
      self.worker_class_name = "#{object.class.to_s.underscore}/#{method}"
      initialize_without_extras(object, method, args)
    end
    
    alias_method_chain :initialize, :extras
    
  end # PerformableMethod
end # Delayed