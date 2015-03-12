module Api::V1
	class Api::ItemsController < ApplicationController
		protect_from_forgery with: :null_session
	end
end