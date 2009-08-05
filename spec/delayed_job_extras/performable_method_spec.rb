require File.dirname(__FILE__) + '/../spec_helper'

describe Delayed::PerformableMethod do
  
  describe 'perform_with_hoptoad' do
    
    it 'should call hoptoad and then re-raise the error' do
      v = Video.create!(:title => 'my video', :file_name => 'my_video.mov')
      HoptoadNotifier.should_receive(:caught).with(instance_of(RuntimeError))
      lambda {
        v.send_later(:encode)
      }.should raise_error(RuntimeError)
    end
    
  end
  
end
