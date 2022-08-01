class UserImagesController < ApplicationController
  # before_action :set_user_image, only: %i[ show update destroy ]
  before_action :delete_image_params, only: %i[ destroy ] 
  include Rails.application.routes.url_helpers
  require 'time'
  require 'openssl'
  require "base64"
  require 'uri'
  require 'addressable/uri'
  # GET /user_images
  def index
    @user_images = ImageUpload.all
    render json: @user_images
  end
  
  
  # GET /user_images/image_key
  def show
  
    authed, message, code = authenticate(request,params[:id])
    if authed == false
      return render json: message, status: code
    end
    blob_client = Azure::Storage::Blob::BlobService.create(storage_account_name: ENV['AZURE_STORAGE_ACCOUNT'], storage_access_key: ENV['AZURE_KEY'])
    nextMarker = nil
    image_key = ""
    found = false
    loop do
        blobs = blob_client.list_blobs(ENV['AZURE_CONTAINER'], { marker: nextMarker })
        blobs.each do |blob|
            if blob.name == params[:id]
              image_key = blob.name
              break
            end
        end
        nextMarker = blobs.continuation_token
        break unless nextMarker && !nextMarker.empty? 
    end

    if image_key.empty?
      return render json: {"message": "Image does not exist"} , status: :not_found
    end
    
    image_url = createSignedQueryString(
      "#{ENV['AZURE_CONTAINER']}/#{image_key}",
      nil,
      'b',
      'r',
      '',
      (Time.now + 5*60).utc.iso8601,
      ''
      # '2021-08-06'
    )
   
    # puts image_url
    image_url = URI.unescape(image_url)
    render json: {"image_url": image_url}, status: :ok
   
  end

  # POST /user_images
  def create
    begin
      res = JSON.parse(RestClient::Request.execute(:url => ENV['AUTH_ENDPOINT'], headers: {Authorization: "#{request.headers["Authorization"]}"}, :method => :get,:verify_ssl => false ),object_class: OpenStruct)
    rescue => exception
      if exception.response.code == 401
        return  render json: {"message": "Unauthorized"}, status: :unauthorized
       end
    end
    if res['message'] != true
      return rendor json: {"message": "Cannot perform this request"}, status: :unauthorized
     end
    
    @user_image = UserImage.new(user_image_params)
    if @user_image.save
      values = []
      @user_image.images.blobs.each do |i|
        values.append({
          # "value": i.url(expires_in: 365.days)
          "image_key": i.key
        })
      end
      render json: values, status: :created
     
    else
      render json: @user_image.errors.full_messages, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user_images/1
  def update
    # if @user_image.update(user_image_params)
    #   render json: @user_image
    # else
    #   render json: @user_image.errors, status: :unprocessable_entity
    # end
  end

  # DELETE /user_images/1
  def destroy
    # @user_image = ActiveStorage::Blob.find_signed!(params[:id])
     
    image_ids =  params[:image_ids].split(",").to_a
    image_ids.each do |key|
      authed, message, code = authenticate(request,key)
      if authed == false
        return render json: message, status: code
      end
    end
   
    invalid_ids = []
    count = 0
    @user_images = ActiveStorage::Blob.find_by(key: image_ids)
    image_ids.each do |id|
      @user_image = ActiveStorage::Blob.find_by(key: id)
      if !@user_image.nil?
        count += 1
      else 
        invalid_ids.push(id)
      end
    end
    if count == image_ids.length
      image_ids.each do |id|
        @user_image = ActiveStorage::Blob.find_by(key: id)
        @user_image.attachments.first.purge
      end
      render json: {"message": "#{count} #{"attachement".pluralize(count)} deleted"}, status: :ok
    else
      render json: {"message": "#{"Image".pluralize(invalid_ids.length)} with #{"id".pluralize(invalid_ids.length)} #{invalid_ids} does not exist"}, status: :not_found
    end
    
  end

  private

  def authenticate(request, image_key)
    begin
      res = JSON.parse(RestClient::Request.execute(:url => ENV['AUTH_ENDPOINT'] + "?user_id=#{request.params['user_id']}", headers: {Authorization: "#{request.headers["Authorization"]}"}, :method => :get,:verify_ssl => false ),object_class: OpenStruct)
    rescue => exception
       if exception.response.code == 401
        return false, "Unauthorized", :unauthorized
       end
    end
   if res['message'] != true
    return false, "Cannot perform this request", :unauthorized
   end
    user_id = res['user_id']
    @user_images = UserImage.where(individual_id: user_id).with_attached_images
    
    is_user_image = false
     @user_images.each do |im|
      im.images.each do |i|
        if i.key == image_key
          is_user_image = true
          break
        end
      end
     end
    if is_user_image == false
      # return render json: {"message": "Unauthorized"} , status: :unauthorized
      # image for this user does not exits or user trying to access image that does not belong to them
      # puts "hello"
      # puts image_key
      return false, "Invalid key" , :not_found
    end

    return true, "Authorized"
  end

  def create_signature(path = '/', resource = 'b', permissions = 'r', start = '', expiry = '', identifier = '')
    # If resource is a container, remove the last part (which is the filename)
    path = path.split('/').reverse.drop(1).reverse.join('/') if resource == 'c'
    puts path
    canonicalizedResource = "/#{ENV['AZURE_STORAGE_ACCOUNT']}/#{path}"
    # signed_version = '2018-11-09'
    stringToSign  = []
    stringToSign << permissions
    stringToSign << start
    stringToSign << expiry
    stringToSign << canonicalizedResource
    stringToSign << identifier
    # stringToSign << signed_version
    stringToSign = stringToSign.join("\n")
    signature    = OpenSSL::HMAC.digest('sha256', Base64.strict_decode64(ENV['AZURE_KEY']), stringToSign.encode(Encoding::UTF_8))
    signature    = Base64.strict_encode64(signature)
  
    return signature
  end

  def createSignedQueryString(path = '/', query_string = '', resource = 'b', permissions = 'r', start = '', expiry = '', identifier = '')
    base = ENV['AZURE_BLOB_URI']
    uri  = Addressable::URI.new
    parts       = {}
    parts[:st]  = URI.unescape(start) unless start == ''
    # parts[:sv] = URI.unescape(signed_version) 
    parts[:se]  = URI.unescape(expiry)
    parts[:sr]  = URI.unescape(resource)
    parts[:sp]  = URI.unescape(permissions)
    parts[:si]  = URI.unescape(identifier) unless identifier == ''
    parts[:sig] = URI.unescape( create_signature(path, resource, permissions, start, expiry,identifier) )
  
    uri.query_values = parts
    return "#{base}/#{path}?#{uri.query}"
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_user_image
      @user_image = UserImage.find(params[:id])
    end
    def delete_image_params
      if params[:image_ids].blank?
        response = { "message" => "parameter image_ids missing" }
        return render json: response, status: :bad_request
      end
    end
    # Only allow a list of trusted parameters through.
    def user_image_params
      params.require(:user_image).permit(:individual_id, :timestamp, :source, :unit, :value, :confidence, images: [])
    end
end
