class AddAttachmentAppToApps < ActiveRecord::Migration
  def self.up
    change_table :apps do |t|
      t.attachment :app
    end
  end

  def self.down
    remove_attachment :apps, :app
  end
end
