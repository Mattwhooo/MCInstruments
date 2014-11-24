class CreateInstrumentedApps < ActiveRecord::Migration
  def change
    create_table :instrumented_apps do |t|
      t.boolean :instrumented

      t.timestamps
    end
  end
end
