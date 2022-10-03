# frozen_string_literal: true

module CurrentSession
  #
  # Base class for providing auth methods
  #
  class Auth
    class_attribute :user_class

    def initialize(request)
      @request = request
    end
    attr_reader :request

    def auth
      request.env["omniauth.auth"]
    end
  end
end
