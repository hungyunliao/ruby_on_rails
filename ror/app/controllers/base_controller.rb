class BaseController < ApplicationController
  include JsonResponse

  def not_found_error
    render json: json_response(RESPONSE_STATUS[:error], {}), status: :not_found
  end
end