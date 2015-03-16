module Api::V1
	class RunesController < Api::V1::BaseController
		protect_from_forgery with: :null_session
	end
end