require 'rubygems'
require 'spec'
require 'singleton'
require File.join(File.dirname(__FILE__), 'database.rb')
require File.join(File.dirname(__FILE__), '..', 'delayed_job', 'lib', 'delayed_job')

module Rails
  class << self
    def version
      '2.3.5'
    end
  end
end
require 'action_mailer'

require File.join(File.dirname(__FILE__), '..', 'lib', 'delayed_job_extras')

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
  end
  
  config.after(:each) do
    ResultCatcher.clear!
    Delayed::Job.delete_all
  end
  
end

module HoptoadNotifier
  def self.notify_or_ignore(*args)
  end
end

class BlockRan < StandardError
end

class SimpleWorker < DJ::Worker
end

require 'logger'
logger = Logger.new(STDOUT)
logger.level = Logger::INFO
RAILS_DEFAULT_LOGGER = logger
