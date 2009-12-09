require File.dirname(__FILE__) + '/../spec_helper'

describe 'ActionMailer' do
  
  it 'should create a worker for an ActionMailer class' do
    Object.const_defined?('PostmanWorker').should be_false
    
    class Postman < ActionMailer::Base
      def welcome_email(user_id, subject)
      end
    end

    Object.const_defined?('PostmanWorker').should be_true
    post = mock('Postman')
    post.should_receive(:deliver!)
    Postman.should_receive(:new).with('welcome_email', 1, 'hello!').and_return(post)
    job = Postman.deliver_welcome_email(1, 'hello!')
    job.invoke_job
  end
  
end