require File.dirname(__FILE__) + '/../spec_helper'

class HoptoadTestWorker < DJ::Worker
  def perform
    raise "Hell!"
  end
end

describe 'Hoptoad' do
  
  it 'should report exceptions to Hoptoad' do
    dj = Delayed::Job.new(:payload_object => HoptoadTestWorker.new, :priority => 0, :run_at => Time.now)
    dj.stub!(:attributes).and_return(:id => 99)
    HoptoadNotifier.should_receive(:notify).with(instance_of(RuntimeError), {:cgi_data => dj.attributes})
    lambda {dj.invoke_job}.should raise_error("Hell!")
  end
  
end