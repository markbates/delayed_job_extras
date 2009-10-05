require File.dirname(__FILE__) + '/../spec_helper'

describe Delayed::Job::Extras do
  
  describe 're_enqueue' do
    
    class RunForeverWorker < DJ::Worker
      re_enqueue {|current, new_worker| new_worker.priority = 795}
      
      def initialize(options, arr)  
      end
      
      def perform
      end
      
    end
    
    it 'should re_enqueue the worker' do
      t = Time.now
      Time.stub!(:now).and_return(t)
      w = RunForeverWorker.new({:foo => :bar}, [1,2,3])
      w.enqueue
      Delayed::Job.should_receive(:enqueue).with(instance_of(RunForeverWorker), 795, t)
      Delayed::Job.work_off
    end
    
  end
  
  describe '__original_args' do
    
    class IHaveArgsWorker < DJ::Worker
      def initialize(a, b, c)
      end
    end
    
    class IHaveNoArgsWorker < DJ::Worker
    end
    
    it 'should be set with the original args' do
      w = IHaveArgsWorker.new(1, 2, 3)
      w.__original_args.should == [1, 2, 3]
      
      w = IHaveNoArgsWorker.new
      w.__original_args.should == nil
    end
    
  end
  
  describe 'enqueue' do
    
    it 'should enqueue the worker' do
      t = 1.week.from_now
      w = SimpleWorker.new
      w.run_at = t
      w.priority = :immediate
      Delayed::Job.should_receive(:enqueue).with(w, 10000, t)
      w.enqueue
    end
    
    it 'should work on the class level' do
      t = Time.now
      Time.stub!(:now).and_return(t)
      Delayed::Job.should_receive(:enqueue).with(instance_of(SimpleWorker), 0, t)
      SimpleWorker.enqueue
    end
    
  end
  
  describe 'logger' do
    
    class LoggerTestWorker < DJ::Worker
    end
    
    it 'should return the DJ::Worker.logger' do
      v = LoggerTestWorker.new
      v.logger.should === DJ::Worker.logger
    end
    
    it 'should return a logger if set' do
      v = LoggerTestWorker.new
      v.logger = ::Logger.new(STDOUT)
      v.logger.should_not === DJ::Worker.logger
    end
    
  end
  
  describe 'worker_class_name' do
    
    class WorkerClassNameTestWorker < DJ::Worker
    end
    
    it 'should return the name of the worker' do
      w = WorkerClassNameTestWorker.new
      w.worker_class_name.should == 'worker_class_name_test_worker'
    end
    
  end
  
  describe 'priority' do
    
    it 'should take a Symbol from the class priority list' do
      w = SimpleWorker.new
      w.priority = :medium
      w.priority.should == 500
    end
    
    it 'should return 0 if it does not recognize the priority' do
      w = SimpleWorker.new
      w.priority = :oops
      w.priority.should == 0
      
      w.priority = 'oops'
      w.priority.should == 0
      
      w.priority = false
      w.priority.should == 0
    end
    
    it 'should return value if defined' do
      w = SimpleWorker.new
      w.priority = 1000
      w.priority.should == 1000
    end
    
    it 'should return 0 as the default priority' do
      w = SimpleWorker.new
      w.priority.should == 0
    end
    
    it 'should be settable at a class level' do
      class PriorityWorkerTest < DJ::Worker
        priority :immediate
      end
      w = PriorityWorkerTest.new
      w.priority.should == 10000
    end
    
  end
  
  describe 'run_at' do
    
    it 'should return a time, if specified' do
      t = 1.week.from_now
      w = SimpleWorker.new
      w.run_at = t
      w.run_at.should == t
    end
    
    it 'should return Time.now, if not specified' do
      now = Time.now
      Time.stub!(:now).and_return(now)
      w = SimpleWorker.new
      w.run_at.should == now
    end
    
  end
  
end