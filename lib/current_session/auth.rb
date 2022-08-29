# frozen_string_literal: true

module CurrentSession
  #
  # Base class for providing auth methods
  #
  class Auth
    def initialize(request, user_class)
      @request = request
      @user_class = user_class
    end
    attr_reader :request, :user_class

    def auth
      request.env["omniauth.auth"]
    end
  end
end
