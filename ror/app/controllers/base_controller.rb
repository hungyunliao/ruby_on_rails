class BaseController < ApplicationController

  def not_found_error
    render json: { 'errors' => { 'id' => ['errors.messages.not_found'] } }, status: :not_found
  end
end