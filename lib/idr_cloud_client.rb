#--
# Copyright 2018 IDRsolutions
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#++
#
# Author:: IDRsolutions (mailto:support@idrsolutions.zendesk.com)
# Copyright:: IDRsolutions
# License:: Apache 2.0

require 'json'
require 'Faraday'


# Used to interact with IDRsolutions' web services
# For detailed usage instructions, see GitHub[https://github.com/idrsolutions/IDRSolutions-Ruby-Client]
class IDRCloudClient

  DOWNLOAD = 'download'
  UPLOAD = 'upload'
  JPEDAL = 'jpedal'
  BUILDVU = 'buildvu'

  @base_endpoint = nil
  @endpoint = nil
  @convert_timeout = nil
  @auth = nil

  # Constructor, setup the converter details
  # Params:
  # +url+:: string, the URL of the web service.
  # +conversion_timeout+:: int, (optional) the time to wait (in seconds) before timing out. Set to 30 by default.
  # +auth+:: array, (optional) the username and password to use for HTTP Authentication. Set to nil by default
  def initialize(url, conversion_timeout: 30, auth: nil)
    @base_endpoint = url
    @endpoint = @base_endpoint
    @convert_timeout = conversion_timeout
    @auth = auth
  end

  # Converts the given file and returns a hash collection with the conversion results. Requires the 'input' and either 'url' or
  # 'file' parameters to run. You can then use the values from the hash, or use methods like download_result().
  # Params:
  # +input+:: string, the method of inputting a file. Examples are IDRCloudClient::UPLOAD or IDRCloudClient::DOWNLOAD
  # +file+:: string, (optional) Location of the PDF to convert, i.e 'path/to/input.pdf'
  # +url+:: string, (optional) the url for the server to download a PDF from
  #
  # Returns: hash [string: string], The results of the conversion
  def convert(**params)
    uuid = upload params

    response = nil
    # check conversion status once every second until complete or error / timeout
    (0..@convert_timeout).each do |i|
      sleep 1
      response = poll_status uuid

      break if response['state'] == 'processed'

      break unless params[:callbackUrl].nil?

      if response['state'] == 'error'
        exMessage = "Failed: Error with conversion\n" 
        response.each do | key, val |
          exMessage = exMessage + "#{key}: $#{val}\n" if key != 'state'
        end
        raise(exMessage)
      end

      raise('Failed: File took longer than ' + @convert_timeout.to_s + ' seconds to convert') if i == @convert_timeout
    end

    response
  end

  # Downloads the zip file produced by the microservice. Provide '.' as the output_file_path if you wish to use the
  # current directory. Will use the filename of the zip on the server if none is specified.
  # Params:
  # +output_file_path+:: string, the output location to save the zip file
  # +file_name+:: string, (optional) the custom name for the zip file. This should not include .zip
  def download_result(results, output_file_path, file_name=nil)
    download_url = results['downloadUrl']

    raise('Error: downloadUrl parameter is empty') if download_url.nil?

    if file_name.nil?
      output_file_path += '/' + download_url.split('/').last
    else
      output_file_path += '/' + file_name + '.zip'
    end

    download download_url, output_file_path
  end

  private

  # Upload file at given path to converter, return UUID if successful
  def upload(params)

    file_path = params.delete(:file)
    params[:file] = Faraday::UploadIO.new(file_path, 'application/pdf') if !file_path.nil?

    uri = URI(@endpoint)
    host = uri.scheme + "://" + uri.host + ':' + uri.port.to_s;

    begin
      conn = Faraday.new(host) do |f|
        f.request :multipart
        f.request :url_encoded
        f.adapter Faraday.default_adapter
        f.basic_auth @auth[:login], @auth[:pass] unless @auth.nil?
      end

      r = conn.post(uri.path, params)

    rescue StandardError => e
      raise("Error sending url:\n" + e.to_s)
    end

    raise "Error uploading file:\n Server returned 401 - Unauthorized" if r.status == 401
    r.status == 200 ? uuid = JSON.parse(r.body)['uuid'] : raise("Error uploading file:\n Server returned response\n" + r.status.to_s + " - " + JSON.parse(r.body)['error'])

    uuid.nil? ? raise("Error uploading file:\nServer returned null UUID") : uuid
  end

  # Check conversion status
  def poll_status(uuid)
    uri = URI(@endpoint)
    host = uri.scheme + "://" + uri.host + ':' + uri.port.to_s;

    begin
      conn = Faraday.new(host) do |req|
          req.params['uuid'] = uuid
          req.request :url_encoded
          req.adapter Faraday.default_adapter
          req.basic_auth @auth[:login], @auth[:pass] unless @auth.nil?
      end
      r = conn.get(uri.path)
    rescue StandardError => e
      raise("Error checking conversion status:\n" + e.to_s)
    end

    r.status == 200 ? response = JSON.parse(r.body) : raise("Error checking conversion status:\n Server returned response\n" + r.status.to_s + " - " + JSON.parse(r.body)['error'])

    response
  end

  # Download converted output to the given location
  def download(download_url, output_file_path)
    conn = Faraday.new download_url do |req|
      req.adapter Faraday.default_adapter
      req.basic_auth @auth[:login], @auth[:pass] unless @auth.nil?
    end
    response = conn.get(download_url)
    File.open(output_file_path, 'wb') { |fp| fp.write(response.body) }

  rescue StandardError => e
    raise('Error downloading conversion output: ' + e.to_s)
  end
end
