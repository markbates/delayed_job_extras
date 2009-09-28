require File.dirname(__FILE__) + '/../spec_helper'

describe DJ::Worker do
  
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
    
    it 'should log' do
      dj_object = mock('dj_object')
      dj_object.should_receive(:id).once.and_return(1)
      dj_object.should_receive(:touch).with(:started_at)
      dj_object.should_receive(:touch).with(:finished_at)
      hw = HelloWorker.new('Mark')
      hw.should_receive(:dj_object).at_least(:once).and_return(dj_object)
      hw.logger.should_receive(:info).with("Starting HelloWorker#perform (DJ.id = '1')")
      hw.logger.should_receive(:info).with("Completed HelloWorker#perform (DJ.id = '1') [SUCCESS]")
      hw.perform.should == 'Mark'
    end
    
  end
  
  describe 'logger' do
    
    it 'should return the DJ::Worker.logger' do
      v = VideoWorker.new
      v.logger.should === DJ::Worker.logger
    end
    
    it 'should return a logger if set' do
      v = VideoWorker.new
      v.logger = ::Logger.new(STDOUT)
      v.logger.should_not === DJ::Worker.logger
    end
    
  end
  
  describe 'self' do
    
    describe 'method_missing' do
      
      it 'should enqueue the worker and pass the args to the initialize method' do
        Delayed::Job.should_receive(:enqueue).with(instance_of(VideoWorker), 0, instance_of(Time))
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
        Delayed::Job.should_receive(:enqueue).with(hw, 1000, instance_of(Time))
        hw.enqueue
      end
      
    end
    
    describe 'priority' do
      
      it 'should set the priority of the job' do
        Delayed::Job.should_receive(:enqueue).with(instance_of(HelloWorker), 1000, instance_of(Time))
        HelloWorker.enqueue('mark')
      end
      
      it 'should translate symbols to ints' do
        Delayed::Job.should_receive(:enqueue).with(instance_of(GoodByeWorker), 500, instance_of(Time))
        GoodByeWorker.enqueue
      end
      
    end
    
  end
  
end
