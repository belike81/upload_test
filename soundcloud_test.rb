require 'sinatra'
require 'json'
require 'base64'

$:.unshift File.dirname(__FILE__)
require 'lib/raw_upload'

class Upload < Sinatra::Base
  use Rack::RawUpload

  get '/' do
    @title = 'Soundcloud upload test app'
    erb :index
  end

  post '/' do
    content_type 'application/json', :charset => 'utf-8' if request.xhr?
    file_path = File.join('uploads/', Time.now.strftime("%Y_%m_%d_%H%M%S") + params[:file][:filename].gsub('/_/', ' '))
    path = File.join(settings.root, 'public/', file_path)
    File.open(path, 'wb') { |f| f.write params[:file][:tempfile].read }

    file_path.to_json
  end

  post '/submit' do
    @posted = params
    @title = 'File submit confirmation'
    erb :submit
  end
end

