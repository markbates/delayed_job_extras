require File.dirname(__FILE__) + '/../spec_helper'

class OneOfAKind < DJ::Worker
  is_unique
  
  def perform
  end
end

class ManyOfAKind < DJ::Worker
  def perform
  end
end

describe Delayed::Job do
  
  describe 'deserialize' do
    
    it 'should deserialize a YAML object' do
      dj = Delayed::Job.new
      source = <<-EOF
      --- !ruby/object:PostmanWorker \nargs: \n- !ruby/object:Email \n  attributes: \n    id: \"1\"\n    user_id: \"1\"\n    address: mark@shortbord.com\n    email_hash: 21f4652e24f47af880f26df92f3122f7\n    token: 356a8a6af69ed9e6bcdf335736bfa68e50754fad\n    state: unconfirmed\n    created_at: 2010-02-05 21:18:12.39589\n    updated_at: 2010-02-05 21:18:12.39589\n  attributes_cache: {}\n\ncalled_method: email_verification\npriority: 10000\nrun_at: 2010-02-08 11:09:17.667792 -05:00\nworker_class_name: postman_worker\n
EOF
      source.strip!
      source.scan(/!ruby\/object:(\S+)\s/).flatten.should == ['PostmanWorker', 'Email']
      # dj.deserialize_with_extras(source)
    end
    
  end
  
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
      2.times do
        lambda {
          job = Delayed::Job.new(:payload_object => ManyOfAKind.new)
          job.save!
        }.should change(Delayed::Job, :count).by(1)
      end
    end
    
  end
  
end