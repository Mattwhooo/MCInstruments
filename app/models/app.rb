require 'fileutils'
require 'securerandom'
class App < ActiveRecord::Base
  has_one :instrumented_app, dependent: :destroy
  has_attached_file :app, s3_permissions: :private
  validates_attachment_content_type :app, content_type: /\A.*\Z/
  after_create :transfer_and_cleanup
  before_create :set_upload_attributes
  DIRECT_UPLOAD_URL_FORMAT = %r{\Ahttps:\/\/s3\.amazonaws\.com\/mcinstruments\/(?<path>uploads\/.+\/(?<filename>.+))\z}.freeze

  def direct_upload_url=(escaped_url)
    write_attribute(:direct_upload_url, (CGI.unescape(escaped_url) rescue nil))
  end

  def transfer_and_cleanup
    direct_upload_url_data = DIRECT_UPLOAD_URL_FORMAT.match(direct_upload_url)
    s3 = AWS::S3.new
    paperclip_file_path = "apps/apps/#{id}/original/#{direct_upload_url_data[:filename]}"
    s3.buckets['mcinstruments'].objects[paperclip_file_path].copy_from(direct_upload_url_data[:path])
    update processed: true
    s3.buckets['mcinstruments'].objects[direct_upload_url_data[:path]].delete
    download_to_local
  end

  def set_upload_attributes
    direct_upload_url_data = DIRECT_UPLOAD_URL_FORMAT.match(direct_upload_url)
    s3 = AWS::S3.new
    direct_upload_head = s3.buckets['mcinstruments'].objects[direct_upload_url_data[:path]].head

    self.app_file_name     = direct_upload_url_data[:filename]
    self.app_file_size     = direct_upload_head.content_length
    self.app_content_type  = direct_upload_head.content_type
    self.app_updated_at    = direct_upload_head.last_modified
  end

  def download_to_local
    uri = URI(app.expiring_url(60))
    file_name = CGI.unescape(uri.path.split('/').last)
    s3_path = 's3://mcinstruments' + CGI.unescape(uri.path)
    fs_dir = Rails.root.to_s + '/public/instrumented_apps/' +  SecureRandom.hex + '/'
    fs_path = fs_dir + 'HPMC_' + file_name
    system("aws s3 cp '" + s3_path + "' '" + fs_path + "'" )

    #run instrumentation

    File.open(fs_path){ |file| InstrumentedApp.create(app: file, app_id: id)}
    FileUtils.rm_rf(fs_dir)
  end

  def download_to_local2
    uri = URI(app.expiring_url(60))
    file_name = CGI.unescape(uri.path.split('/').last)
    http = Net::HTTP.new(uri.host)
    http.start() { |http|
      req = Net::HTTP::Get.new(uri.path + '?' + uri.query)
      response = http.request(req)
      tempfile = Tempfile.new(file_name)
      File.open(tempfile.path,'w') do |f|
        f.write response.body.to_s.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
      end
      FileUtils.mv(tempfile.path, Rails.root.to_s + '/public/' + file_name)
      system('cd ' + Rails.root.to_s + '/public; ls')
    }
  end
  def test_echo
    system 'ls'
  end

end
