class Image < ActiveRecord::Base
	belongs_to :imageables, polymorphic: true
end
