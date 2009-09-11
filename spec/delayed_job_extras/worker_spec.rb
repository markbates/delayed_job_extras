require File.dirname(__FILE__) + '/../spec_helper'

describe Delayed::Worker do
  
  it 'should receive the DJ object when performed' do
    vw = GoodByeWorker.new
    vw.should_receive(:dj_object=).with(instance_of(Delayed::Job))
    job = Delayed::Job.new
    job.stub(:payload_object=).with(vw)
    job.stub(:payload_object).and_return(vw)
    job.invoke_job
    #(:payload_object => vw, :priority => 0, :run_at => Time.now)
  end
  
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
        Delayed::Job.should_receive(:enqueue).with(instance_of(VideoWorker), :priority => 0)
        VideoWorker.encode(1)
      end
      
    end
    
    describe 'enqueue' do
      
      it 'should enqueue the worke and pass the args to the initialize method' do
        w = mock('video_worker')
        w.should_receive(:enqueue)
        VideoWorker.should_receive(:new).with(1).and_return(w)
        VideoWorker.enqueue(1)
      end
      
      it 'should enqueue the worker' do
        hw = HelloWorker.new('mark')
        Delayed::Job.should_receive(:enqueue).with(hw, :priority => 1000)
        hw.enqueue
      end
      
    end
    
    describe 'priority' do
      
      it 'should set the priority of the job' do
        Delayed::Job.should_receive(:enqueue).with(instance_of(HelloWorker), :priority => 1000)
        HelloWorker.enqueue('mark')
      end
      
      it 'should translate symbols to ints' do
        Delayed::Job.should_receive(:enqueue).with(instance_of(GoodByeWorker), :priority => 500)
        GoodByeWorker.enqueue
      end
      
    end
    
  end
  
end
