require File.dirname(__FILE__) + '/../spec_helper'

describe Delayed::PerformableMethod do
  
  describe 'worker_class_name' do
    
    class Foo
    end
    
    it 'should return the name of the object' do
      w = Delayed::PerformableMethod.new(Foo.new, :to_s, [])
      w.worker_class_name.should == 'foo/to_s'
    end
    
  end
  
end