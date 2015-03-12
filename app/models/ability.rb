class Ability < ActiveRecord::Base
	belongs_to :champion
	has_many :coefficients
	has_many :images, as: :imageable
	def index
	end


	private

	def ability_params
		params.require(:ability).permit(
			:ability_id,
			:name,
			:description,
			:tooltip,
			:leveltip_label,
			:leveltip_effect,
			:maxrank,
			:cooldown,
			:cooldownBurn,
			:cost,
			:costBurn,
			:effect,
			:effectBurn,
			:costType,
			:range,
			:rangeBurn,
			:champion_id
		)
	end
end
