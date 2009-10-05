require File.dirname(__FILE__) + '/../spec_helper'

class HoptoadTestWorker < DJ::Worker
  def perform
    raise "Hell!"
  end
end

describe 'Hoptoad' do
  
  it 'should report exceptions to Hoptoad' do
    dj = Delayed::Job.new(:payload_object => HoptoadTestWorker.new, :priority => 0, :run_at => Time.now)
    dj.should_receive(:notify_hoptoad).with(instance_of(Hash))
    lambda {dj.invoke_job}.should raise_error("Hell!")
  end
  
end