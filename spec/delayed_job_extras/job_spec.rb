require File.dirname(__FILE__) + '/../spec_helper'

describe Delayed::Job do
  
  describe 'reset!' do
    
    it 'should reset the job so to prestine conditions' do
      now = Time.now
      later = Time.now + 10000
      Time.stub(:now).and_return(now)
      
      dj = Delayed::Job.new(:run_at => later, :attempts => 10, :last_error => 'Oops!')
      dj.should_receive(:save!)
      dj.should_receive(:reload)
      
      dj.run_at.should == later
      dj.attempts.should == 10
      dj.last_error.should == 'Oops!'
      
      dj.reset!
      dj.run_at.should == now
      dj.attempts.should == 0
      dj.last_error.should be_nil
    end
    
  end
  
  describe 'invoke_job_with_extras' do
    
    it 'should touch timestamps and log started/completed' do
      payload = mock('payload')
      payload.should_receive(:class).at_least(:once).and_return(SimpleWorker)
      payload.should_receive(:re_enqueuable).and_return(false)
      
      dj = Delayed::Job.new
      dj.should_receive(:payload_object).at_least(:once).and_return(payload)
      dj.should_receive(:id).at_least(:once).and_return(99)
      dj.should_receive(:touch).with(:started_at)
      dj.should_receive(:touch).with(:finished_at)
      dj.stub!(:invoke_job_without_extras)
      
      payload.should_receive(:dj_object=).with(dj)
      
      DJ::Worker.logger.should_receive(:info).with("Starting SimpleWorker#perform (DJ.id = '99')")
      DJ::Worker.logger.should_receive(:info).with("Completed SimpleWorker#perform (DJ.id = '99') [SUCCESS]")
      
      dj.invoke_job
    end
    
    it 'should log a failure and rollback the started_at timestamp' do
      payload = mock('payload')
      payload.should_receive(:class).at_least(:once).and_return(SimpleWorker)
      payload.should_receive(:perform).and_raise("Hell!")
      
      dj = Delayed::Job.new
      dj.should_receive(:payload_object).at_least(:once).and_return(payload)
      dj.should_receive(:id).at_least(:once).and_return(99)
      dj.should_receive(:touch).with(:started_at)
      dj.should_receive(:update_attributes).with(:started_at => nil)
      
      payload.should_receive(:dj_object=).with(dj)
      
      DJ::Worker.logger.should_receive(:info).with("Starting SimpleWorker#perform (DJ.id = '99')")
      DJ::Worker.logger.should_receive(:error).with("Halted SimpleWorker#perform (DJ.id = '99') [FAILURE]")
      
      lambda {dj.invoke_job}.should raise_error("Hell!")
    end
    
  end
  
  describe 'pending?' do
    
    it 'should be true if the job is queued, but not running' do
      dj = Delayed::Job.new
      dj.should be_pending
    end
    
  end
  
  describe 'running?' do
    
    it 'should be true if the job is running, but not finished' do
      dj = Delayed::Job.new
      dj.started_at = Time.now
      dj.should be_running
    end
    
  end
  
  describe 'finished?' do
    
    it 'should be true if the job is finished running' do
      dj = Delayed::Job.new
      dj.started_at = Time.now
      dj.finished_at = Time.now
      dj.should be_finished
    end
    
  end
  
  describe 'payload_object=' do
    
    it 'should assign the worker_class_name to the dj instance' do
      x = 'Hi!'
      x.instance_eval do
        def worker_class_name
          'string'
        end
      end
      dj = Delayed::Job.new(:payload_object => x)
      dj.worker_class_name.should == 'string'
    end
    
    it 'should assign unknown as the worker_class_name if there is not one' do
      dj = Delayed::Job.new
      dj.worker_class_name.should == 'unknown'
    end
    
  end
  
  describe 'unique?' do
    
    it 'should only allow 1 instance at a time in the queue' do
      class OneOfAKind < DJ::Worker
        def unique?
          true
        end
        def perform
        end
      end
      lambda {
        job = Delayed::Job.new(:payload_object => OneOfAKind.new)
        job.save!
      }.should change(Delayed::Job, :count).by(1)
      
      lambda {
        job = Delayed::Job.new(:payload_object => OneOfAKind.new)
        job.save.should be_false
        job.errors[:base].should include("Only one one_of_a_kind can be queued at a time!")
      }.should_not change(Delayed::Job, :count)
    end
    
    it 'should let many workers in the queue if false' do
      class ManyOfAKind < DJ::Worker
        def perform
        end
      end
      2.times do
        lambda {
          job = Delayed::Job.new(:payload_object => ManyOfAKind.new)
          job.save!
        }.should change(Delayed::Job, :count).by(1)
      end
    end
    
  end
  
end