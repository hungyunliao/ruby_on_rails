module JsonResponse
  extend ActiveSupport::Concern

  RESPONSE_STATUS = {
    success: 'success',
    error:   'error'
  }

end