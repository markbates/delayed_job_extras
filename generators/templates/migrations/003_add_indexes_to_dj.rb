class AddIndexesToDj < ActiveRecord::Migration
  def self.up
    add_index :delayed_jobs, :priority
    add_index :delayed_jobs, :worker_class_name
    add_index :delayed_jobs, :deleted_at
    add_index :delayed_jobs, :run_at
  end

  def self.down
    remove_index :delayed_jobs, :run_at
    remove_index :delayed_jobs, :deleted_at
    remove_index :delayed_jobs, :worker_class_name
    remove_index :delayed_jobs, :priority
  end
end
