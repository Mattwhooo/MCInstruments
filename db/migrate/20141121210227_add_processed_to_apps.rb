class AddProcessedToApps < ActiveRecord::Migration
  def change
    add_column :apps, :processed, :boolean
  end
end
