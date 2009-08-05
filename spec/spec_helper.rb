require 'rubygems'
require 'spec'
require File.join(File.dirname(__FILE__), 'database.rb')
require File.join(File.dirname(__FILE__), '..', 'delayed_job', 'lib', 'delayed_job')

require File.join(File.dirname(__FILE__), '..', 'lib', 'delayed_job_extras')
require File.join(File.dirname(__FILE__), '..', 'lib', 'delayed_job_test_enhancements')

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
  def self.caught(e)
  end
  
  module Catcher
    
    def notify_hoptoad(e)
      HoptoadNotifier.caught(e)
    end
    
  end
end

class Video < ActiveRecord::Base
  
  def encode
    raise 'Hell!'
  end
  
end

class VideoWorker < Delayed::Worker
  
  def initialize(*args)
    
  end
  
  perform do
    raise BlockRan.new
  end
  
end

class VideoErrorWorker < Delayed::Worker
  
  perform do
    raise 'Hell!'
  end
  
end

class HelloWorker < Delayed::Worker
  
  attr_accessor :my_name
  
  def initialize(name)
    self.my_name = name
  end
  
  perform do
    self.my_name
  end
  
end

class BlockRan < StandardError
end

require 'logger'
logger = Logger.new(STDOUT)
logger.level = Logger::INFO
RAILS_DEFAULT_LOGGER = logger
