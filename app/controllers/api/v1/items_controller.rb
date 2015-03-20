module Api::V1
	class ItemsController < Api::V1::BaseController
		protect_from_forgery with: :null_session

    def index
      plural_resource_name = "@#{resource_name.pluralize}"
      resources = resource_class.where(query_params).includes('image')
                                #.page(page_params[:page])
                                #.per(page_params[:page_size])
      instance_variable_set(plural_resource_name, resources)
      render :index, status: :ok
    end


    private 

    def set_resource(resource = nil)
      resource ||= resource_class.find_by_item_id(params[:id])
      instance_variable_set("@#{resource_name}", resource)
    end

	end
end