module JsonResponse
  extend ActiveSupport::Concern

  RESPONSE_STATUS = {
    success: 'success',
    error:   'error'
  }

  def json_response(status, message = '')
    {
      status:   status,
      message:  message
    }
  end

end