if defined?(ActionMailer)
  module ActionMailer
    class Base
        
      def self.inherited(klass)
        super
        eval %{
          class ::#{klass}Worker < DJ::Worker

            attr_accessor :called_method
            attr_accessor :args

            def initialize(called_method, *args)
              self.called_method = called_method
              self.args = args
            end

            def perform
              ::#{klass}.send(self.called_method, *self.args)
            end
            
            class << self
              
              def method_missing(sym, *args)
                ::#{klass}Worker.enqueue(sym, *args)
              end
              
            end

          end
        }
      end
      
    end # Base
  end # ActionMailer
end