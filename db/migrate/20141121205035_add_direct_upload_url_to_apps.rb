class AddDirectUploadUrlToApps < ActiveRecord::Migration
  def change
    add_column :apps, :direct_upload_url, :string
  end
end
