class Skin < ActiveRecord::Base
	belongs_to :champion
	has_one :image, as: :imageable, dependent: :destroy
end
