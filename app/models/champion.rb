class Champion < ActiveRecord::Base
	has_many :abilities
	has_many :skins
	has_one :passive
end
