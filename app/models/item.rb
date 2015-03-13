class Item < ActiveRecord::Base
	has_one :image, as: :imageable, dependent: :destroy
end