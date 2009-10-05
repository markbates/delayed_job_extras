require File.dirname(__FILE__) + '/../spec_helper'

describe 'ActionMailer' do
  
  it 'should create a worker for an ActionMailer class' do
    Object.const_defined?('PostmanWorker').should be_false
    
    class Postman < ActionMailer::Base
      def deliver_welcome_email(user_id, subject)
      end
    end

    Object.const_defined?('PostmanWorker').should be_true
    Postman.should_receive(:deliver_welcome_email).with(1, 'hello!')
    PostmanWorker.deliver_welcome_email(1, 'hello!')
    Delayed::Job.work_off
  end
  
end