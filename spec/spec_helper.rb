require 'rubygems'
require 'spec'

require File.join(File.dirname(__FILE__), '..', 'lib', 'delayed_job_extras')

Spec::Runner.configure do |config|
  
  config.before(:all) do
    
  end
  
  config.after(:all) do
    
  end
  
  config.before(:each) do
    
  end
  
  config.after(:each) do
    
  end
  
end

module HoptoadNotifier
  module Catcher
    
    def notify_hoptoad(e)
    end
    
  end
end

class VideoWorker < Delayed::BaseWorker
  
  def perform
    super do
      raise BlockRan.new
    end
  end
  
end

class VideoErrorWorker < Delayed::BaseWorker
  
  def perform
    super do
      raise 'Hell!'
    end
  end
  
end

class BlockRan < StandardError
end
