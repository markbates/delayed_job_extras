require File.dirname(__FILE__) + '/../spec_helper'

describe Delayed::BaseWorker do
  
  describe 'task_name' do
    
    it 'should return the underscored class name' do
      v = VideoWorker.new
      v.task_name.should == 'video_worker'
    end
    
  end
  
  describe 'perform' do
    
    it 'should yield up to a block' do
      w = VideoWorker.new
      lambda {
        w.perform
      }.should raise_error(BlockRan)
    end
    
    it 'should call hoptoad and then re-raise the error' do
      w = VideoErrorWorker.new
      w.should_receive(:notify_hoptoad).with(instance_of(RuntimeError))
      lambda {
        w.perform
      }.should raise_error(RuntimeError)
    end
    
  end
  
end
