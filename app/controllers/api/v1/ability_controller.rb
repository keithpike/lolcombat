module Api::V1
	class AbilitiesController < Api::V1::BaseController
	




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
end