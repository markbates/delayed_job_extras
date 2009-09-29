require File.dirname(__FILE__) + '/../spec_helper'

describe Delayed::PerformableMethod do
  
  describe 'running?' do
    
    it 'should be set when the job starts' do
      gb = Delayed::PerformableMethod.new(GobstopperWorker.new, :perform, [])
      jb = Delayed::Job.create(:payload_object => gb, :priority => 0, :run_at => Time.now)
      jb.should_receive(:touch).with(:started_at)
      jb.should_receive(:touch).with(:finished_at)
      jb.invoke_job
    end
    
    it 'should be rolled back if the job fails' do
      gb = Delayed::PerformableMethod.new(FlobstopperWorker.new, :perform, [])
      jb = Delayed::Job.create(:payload_object => gb, :priority => 0, :run_at => Time.now)
      jb.should_receive(:touch).with(:started_at)
      jb.should_receive(:update_attributes).with(:started_at => nil)
      lambda {jb.invoke_job}.should raise_error
    end
    
  end
  
  describe 'finished?' do
    
    it 'should be set when the job starts' do
      gb = Delayed::PerformableMethod.new(GobstopperWorker.new, :perform, [])
      jb = Delayed::Job.create(:payload_object => gb, :priority => 0, :run_at => Time.now)
      jb.should_receive(:touch).with(:started_at)
      jb.should_receive(:touch).with(:finished_at)
      jb.invoke_job
    end
    
  end
  
  describe 'perform_with_hoptoad' do
    
    it 'should call hoptoad and then re-raise the error' do
      v = Video.create!(:title => 'my video', :file_name => 'my_video.mov')
      HoptoadNotifier.should_receive(:caught).with(instance_of(RuntimeError))
      lambda {
        v.send_later(:encode)
      }.should raise_error(RuntimeError)
    end
    
    it 'should log' do
      DJ::Worker.logger.should_receive(:info).with("Starting Delayed::PerformableMethod#perform (DJ.id = '')")
      DJ::Worker.logger.should_receive(:error).with("Halted Delayed::PerformableMethod#perform (DJ.id = '') [FAILURE]")
      v = Video.create!(:title => 'my video', :file_name => 'my_video.mov')
      HoptoadNotifier.should_receive(:caught).with(instance_of(RuntimeError))
      lambda {
        v.send_later(:encode)
      }.should raise_error(RuntimeError)
    end
    
  end
  
end
