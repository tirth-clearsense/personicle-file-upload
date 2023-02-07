class UserImage < ApplicationRecord
    # has_one_attached :image
    has_many_attached :images
    # after_create :set_filename
    validate :image_type
    # validates_uniqueness_of :user_images, :scope => [:individual_id, :timestamp, :source]
    def image_urls
        # Rails.application.routes.url_helpers.url_for(image) if image.attached?
        images.map{|i| Rails.application.routes.url_helpers.url_for(i) }
    end
   
    private

    def image_type
    if images.attached? == false
        errors.add(:images, "are missing!")
    end
    images.each do |i|
        if !i.content_type.in?(%('image/jpeg image/png image/jpg'))
            errors.add(:images, "needs to be a jpeg or png!")
        end
        if i.byte_size > 6.megabytes
            errors.add(:images,"should be less than 5MB")
        end
    end
   
   
    end
end
