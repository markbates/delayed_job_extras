require File.dirname(__FILE__) + '/../spec_helper'

describe Delayed::Worker do
  
  describe 'worker_class_name' do
    
    it 'should return the underscored class name' do
      v = VideoWorker.new
      v.worker_class_name.should == 'video_worker'
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
    
    it 'should use the instance of itself as the binding' do
      hw = HelloWorker.new('Mark')
      hw.perform.should == 'Mark'
    end
    
  end
  
  describe 'logger' do
    
    it 'should return the RAILS_DEFAULT_LOGGER' do
      v = VideoWorker.new
      v.logger.should be_kind_of(Logger)
      v.logger.should == RAILS_DEFAULT_LOGGER
    end
    
  end
  
  describe 'self' do
    
    describe 'method_missing' do
      
      it 'should enqueue the worker and pass the args to the initialize method' do
        w = mock('video_worker')
        VideoWorker.should_receive(:new).with(:encode, 1).and_return(w)
        Delayed::Job.should_receive(:enqueue).with(w)
        VideoWorker.encode(1)
      end
      
    end
    
    describe 'enqueue' do
      
      it 'should enqueue the worke and pass the args to the initialize method' do
        w = mock('video_worker')
        VideoWorker.should_receive(:new).with(1).and_return(w)
        Delayed::Job.should_receive(:enqueue).with(w)
        VideoWorker.enqueue(1)
      end
      
    end
    
  end
  
end
