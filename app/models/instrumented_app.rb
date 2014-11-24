class InstrumentedApp < ActiveRecord::Base
  belongs_to :app
  has_attached_file :app, s3_permissions: :private
  validates_attachment_content_type :app, content_type: /\A.*\Z/



  def from_url url
    self.app = URI.parse(url)
  end
end
