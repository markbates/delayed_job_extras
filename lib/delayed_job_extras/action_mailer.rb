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
              # ::#{klass}.send(self.called_method, *self.args)
              ::#{klass}.send(:new, self.called_method, *self.args).deliver!
            end
            
            class << self
              
              def method_missing(sym, *args)
                ::#{klass}Worker.enqueue(sym, *args)
              end
              
            end

          end
        }
      end
      
      class << self
        
        def method_missing(method_symbol, *parameters) #:nodoc:
          if match = matches_dynamic_method?(method_symbol)
            case match[1]
              when 'deliver'# then new(match[2], *parameters).deliver!
                "#{self.name}Worker".constantize.enqueue(match[2], *parameters)
              else super
            end
          else
            super
          end
        end
        
      end
      
    end # Base
  end # ActionMailer
end