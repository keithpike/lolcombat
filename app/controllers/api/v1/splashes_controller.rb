module Api::V1
	class SplashesController < Api::V1::BaseController
		protect_from_forgery with: :null_session
	end
end