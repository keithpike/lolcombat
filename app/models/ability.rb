class Ability < ActiveRecord::Base
	belongs_to :champion
	has_many :coefficients
	has_one :image, as: :imageable, dependent: :destroy

end
