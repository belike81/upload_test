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

    path = File.join(Dir.pwd, 'public/uploads', Base64.encode64(Time.now.to_s) + params[:file][:filename])
    File.open(path, 'wb') { |f| f.write params[:file][:tempfile].read }
    path.to_json
  end

  post '/submit' do
    @posted = params
    @title = 'File submit confirmation'
    erb :submit
  end
end

