class Skin < ActiveRecord::Base
	has_one :image, as: :imageable
	belongs_to :champion
end
