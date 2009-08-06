require File.dirname(__FILE__) + '/../spec_helper'

describe Delayed::Job do
  
  describe 'stats' do
    
    it 'should return stats for all the workers' do
      # Delayed::Job.find_with_destroyed(:all, :select => :worker_class_name, :group => :worker_class_name)
      workers = []
      w1 = mock('worker_one')
      w1.should_receive(:worker_class_name).at_least(:once).and_return('worker_one')
      workers << w1
      wnil = mock('worker_nil')
      wnil.should_receive(:worker_class_name).at_least(:once).and_return(nil, 'UNKNOWN')
      wnil.should_receive(:worker_class_name=).with('UNKNOWN')
      workers << wnil
      
      Delayed::Job.should_receive(:find_with_destroyed).with(:all, :select => :worker_class_name, :group => :worker_class_name).and_return(workers)
      Delayed::Job.should_receive(:count_with_destroyed).with(:conditions => {:worker_class_name => 'worker_one'}).and_return(100)
      Delayed::Job.should_receive(:count).with(:conditions => {:worker_class_name => 'worker_one'}).and_return(75)
      Delayed::Job.should_receive(:count).with(:conditions => ['worker_class_name = ? and attempts > 1', 'worker_one']).and_return(10)
      
      Delayed::Job.should_receive(:count_with_destroyed).with(:conditions => {:worker_class_name => nil}).and_return(10)
      Delayed::Job.should_receive(:count).with(:conditions => {:worker_class_name => nil}).and_return(0)
      Delayed::Job.should_receive(:count).with(:conditions => ['worker_class_name = ? and attempts > 1', nil]).and_return(0)
      
      stats = Delayed::Job.stats(nil, nil)
      worker_one = stats['worker_one']
      worker_one.should_not be_nil
      worker_one[:total].should == 100
      worker_one[:remaining].should == 75
      worker_one[:processed].should == 25
      worker_one[:failures].should == 10
      
      worker_nil = stats['UNKNOWN']
      worker_nil.should_not be_nil
      worker_nil[:total].should == 10
      worker_nil[:remaining].should == 0
      worker_nil[:processed].should == 10
      worker_nil[:failures].should == 0
    end
    
  end
  
end
