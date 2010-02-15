class RunForeverWorker < DJ::Worker
  re_enqueue {|current, new_worker| new_worker.priority = 795}
  
  def initialize(options)
  end
  
  def perform
  end
  
end

class RunForeverWithoutOptionsWorker < DJ::Worker
  re_enqueue {|current, new_worker| new_worker.priority = 795}
  
  def initialize
  end
  
  def perform
  end
  
end

class IHaveArgsWorker < DJ::Worker
  attr_accessor :a
  attr_accessor :b
  attr_accessor :c
  def initialize(a, b, c)
    self.a = a
    self.b = b
    self.c = c
  end
end

class ILikeHashArgsWorker < DJ::Worker
  attr_accessor :options
  def initialize(options)
    self.options = options
  end
end

class WorkerClassNameTestWorker < DJ::Worker
end