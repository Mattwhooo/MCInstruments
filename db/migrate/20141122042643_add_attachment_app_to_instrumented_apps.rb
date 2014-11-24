class AddAttachmentAppToInstrumentedApps < ActiveRecord::Migration
  def self.up
    change_table :instrumented_apps do |t|
      t.attachment :app
    end
  end

  def self.down
    remove_attachment :instrumented_apps, :app
  end
end
