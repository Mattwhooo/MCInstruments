class AppsController < ApplicationController
  def index
    @apps = App.all
  end

  def new
    @app = App.new
  end

  def create
    app = App.new( app_params )
    app.app_file_name = params[:filename]
    app.app_content_type = params[:filetype]
    app.app_file_size = params[:filesize]
    app.direct_upload_url = params[:app][:direct_upload_url]
    app.save
    redirect_to (:back)
  end

  def download
    redirect_to App.find(params[:id]).app.expiring_url(300)
  end

  def download_instrumented
    redirect_to App.find(params[:id]).instrumented_app.app.expiring_url(300)
  end

  def destroy
    App.find(params[:id]).destroy
    @apps = App.all
    redirect_to :apps
  end

  private

# Use strong_parameters for attribute whitelisting
# Be sure to update your create() and update() controller methods.

  def app_params
    params.require(:app).permit(:app)
  end
end
