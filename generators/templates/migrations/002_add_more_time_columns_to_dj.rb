class AddMoreTimeColumnsToDj < ActiveRecord::Migration
  def self.up
    add_column :delayed_jobs, :started_at, :datetime
    add_column :delayed_jobs, :finished_at, :datetime
  end

  def self.down
    remove_column :delayed_jobs, :finished_at
    remove_column :delayed_jobs, :started_at
  end
end