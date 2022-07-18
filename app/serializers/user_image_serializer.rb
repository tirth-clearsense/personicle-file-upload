class UserImageSerializer
    include JSONAPI::Serializer
    attributes :id, :individual_id, :timestamp, :source, :value, :confidence, :image_urls
  end
  