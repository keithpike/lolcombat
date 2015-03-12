module Api::V1
	class Api::MasteriesController < ApplicationController
		protect_from_forgery with: :null_session
	end
end
