require 'rubygems'
require 'spec'
require 'singleton'
require File.join(File.dirname(__FILE__), 'database.rb')
require File.join(File.dirname(__FILE__), '..', 'delayed_job', 'lib', 'delayed_job')

require File.join(File.dirname(__FILE__), '..', 'lib', 'delayed_job_extras')
require File.join(File.dirname(__FILE__), '..', 'lib', 'delayed_job_test_enhancements')

class ResultCatcher
  include Singleton
  attr_accessor :results
  
  def initialize
    self.clear!
  end
  
  def clear!
    self.results = []
  end
  
  class << self
    def method_missing(sym, *args)
      ResultCatcher.instance.send(sym, *args)
    end
  end
  
end

Spec::Runner.configure do |config|
  
  config.before(:all) do
    
  end
  
  config.after(:all) do
    
  end
  
  config.before(:each) do
    ResultCatcher.clear!
    Delayed::Job.delete_all
    Video.delete_all
  end
  
  config.after(:each) do
    ResultCatcher.clear!
    Delayed::Job.delete_all
    Video.delete_all
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
  
  def decode
  end
  
end

class VideoWorker < DJ::Worker
  
  def initialize(*args)
    
  end
  
  perform do
    raise BlockRan.new
  end
  
end

class VideoErrorWorker < DJ::Worker
  
  perform do
    raise 'Hell!'
  end
  
end

class HelloWorker < DJ::Worker
  
  attr_accessor :my_name
  priority 1000
  
  def initialize(name)
    self.my_name = name
  end
  
  perform do
    self.my_name
  end
  
end

class GoodByeWorker < DJ::Worker
  
  priority :medium
  
  perform do
  end
  
end

class BlockRan < StandardError
end

class GobstopperWorker < DJ::Worker
  perform do
  end
end

class FlobstopperWorker < DJ::Worker
  perform do
    raise Hell!
  end
end

require 'logger'
logger = Logger.new(STDOUT)
logger.level = Logger::INFO
RAILS_DEFAULT_LOGGER = logger
