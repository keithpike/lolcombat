module Api::V1
	class Api::RunesController < ApplicationController
		protect_from_forgery with: :null_session
	end
end