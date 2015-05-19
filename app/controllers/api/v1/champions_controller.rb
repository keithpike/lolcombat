module Api::V1
	class ChampionsController < Api::V1::BaseController
		# def index
		# 	render json: Champion.all
		# end

		def index
      plural_resource_name = "@#{resource_name.pluralize}"
      resources = resource_class.where(query_params).includes('image')
                                #.page(page_params[:page])
                                #.per(page_params[:page_size])
      instance_variable_set(plural_resource_name, resources)
  		render :index
    end

   #  def show
   #  	# todo: add friendly id gem to allow to search by name as well
			# @champion = Champion.find_by_key(params[:id])
   #    render :show
   #  end

		# def create
		# 	render json: "Create functionality is not available until authentication is added"
		# 	# add after I put up some form of authentication

		# 	# riot_champs = RiotApiHandler.new().get_resources('./champion', 'champion')
		# 	# riot_champs.each do |champ|
		# 	#	  Champion.create(champ)
		# 	# end

		# 	# render json: "champs created"
		# end

		# def update
		# # 	# add after I put up some form of authentication
		# 	render json: "Update functionality is not available until authentication is added"
		# end

		# def destroy
		# 	render json: "Delete functionality is DEFINITELY not available until authentication is added"
		# # 	# add after I put up some form of authentication
		# # 	Champion.find_by_id(params[:id]).delete
		# end


		private

    def set_resource(resource = nil)
      resource ||= resource_class.find_by_clean_name(params[:id])
      instance_variable_set("@#{resource_name}", resource)
    end

		def champion_params
			params.require(:champion).permit(
				:champion_id,
				:key,
				:name,
				:clean_name,
				:title,
				:lore,
				:allytips,
				:enemytips,
				:tags,
				:hp,
				:hp_per_level,
				:mp,
				:mp_per_level,
				:movespeed,
				:armor,
				:armor_per_level,
				:spellblock,
				:spellblock_per_level,
				:attackrange,
				:hpregen,
				:hpregen_per_level,
				:mpregen,
				:mpregen_per_level,
				:crit,
				:crit_per_level,
				:attackdamage,
				:attackdamage_per_level,
				:attackspeedoffset,
				:attackspeed_per_level
			)
		end

	end
end