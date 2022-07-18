class UserImagesController < ApplicationController
  # before_action :set_user_image, only: %i[ show update destroy ]
  include Rails.application.routes.url_helpers
  # GET /user_images
  def index
    @user_images = ImageUpload.all

    render json: @user_images
  end

  # GET /user_images/1
  # GET /user_images/user_id

  def show
    begin
      res = RestClient::Request.execute(:url => ENV['AUTH_ENDPOINT'], :method => :get, headers: {Authorization: "#{request.headers["Authorization"]}"})
      if res.code == 200
        if JSON.parse(res)['user_id'] == params[:id]
          @image_uploads = ImageUpload.where(individual_id: params[:id] )
          return render json: @image_uploads
        else
          return render json: "Not authorized to access this data",  status: :unauthorized
        end
      end
    rescue => e
      case e.response.code
      when 401
        return render json: e.response,  status: :unauthorized
      else
        return render json: e.response,  status: :bad_request
    end 
  
    end
    # puts res
   
  end

  # POST /user_images
  def create
    @user_image = UserImage.new(user_image_params)
    if @user_image.save
   
    values = []
    @user_image.images.blobs.each do |i|
      values.append({
        "question-id": "test",
        "value": i.url
      })
    
    end
     
    #  @user_image.image_urls.each do |url|
    #   values.append({
    #     "question-id": "test",
    #     "value": url
    #   })
    #  end
      #  create data packet and send to write api
      data = {"streamName": "com.personicle.individual.datastreams.subjective.image_uploads", "individual_id": "test",
      "source": "Personicle:image_upload", "unit": "", "confidence": 100, "dataPoints":[
       { "timestamp": Time.now.strftime("%Y-%m-%d %H:%M:%S.%6N"),
         "value": values
       }
     ]
      }
  #  puts @user_image.image_urls.class
      res = RestClient::Request.execute(:url => ENV['DATASTREAM_UPLOAD'], :payload => data.to_json, :method => :post, headers: {Authorization: "Bearer #{request.headers["Authorization"]}", content_type: :json})
      # render json: @user_image, status: :created, location: @user_image
      # puts res.code
      puts res
      render json: UserImageSerializer.new(@user_image).serializable_hash[:data][:attributes], status: :created
    else
      render json: @user_image.errors.full_messages, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user_images/1
  def update
    if @user_image.update(user_image_params)
      render json: @user_image
    else
      render json: @user_image.errors, status: :unprocessable_entity
    end
  end

  # DELETE /user_images/1
  def destroy
    @user_image.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_image
      @user_image = UserImage.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_image_params
      params.require(:user_image).permit(:individual_id, :timestamp, :source, :unit, :value, :confidence, images: [])
    end
end
