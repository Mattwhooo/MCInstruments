class AddAppIdToInstrumentedApp < ActiveRecord::Migration
  def change
    add_column :instrumented_apps, :app_id, :integer
  end
end
