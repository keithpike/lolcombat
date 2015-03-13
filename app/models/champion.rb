class Champion < ActiveRecord::Base
	has_many :abilities
	has_many :skins
	has_one :passive
	has_one :image, as: :imageable, dependent: :destroy
	has_many :splashes

	validates :champion_id, presence: true
	validates :key, presence: true
	validates :name, presence: true

end



# class Tagging < ActiveRecord::Base
#   belongs_to :taggable, :polymorphic => true
#   belongs_to :tag
# end
# And your taggable models, Book and Movie.

# class Book < ActiveRecord::Base
#   has_many :taggings, :as => :taggable
#   has_many :tags, :through => :taggings
# end
    
# class Movie < ActiveRecord::Base
#   has_many :taggings, :as => :taggable
#   has_many :tags, :through => :taggings
# end