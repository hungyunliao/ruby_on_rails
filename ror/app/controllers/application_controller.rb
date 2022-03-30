class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordNotFound, with: :not_found_error
end
