module JsonResponse
    extend ActiveSupport::Concern

    RESPONSE_STATUS = {
        :SUCCESS => "success",
        :ERROR => "error"
    }

end