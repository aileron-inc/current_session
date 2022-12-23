# frozen_string_literal: true

module CurrentSession
  #
  # auth method
  #
  class AuthMethod
    def self.new_class(methods)
      Class.new(self) { include methods }
    end

    def initialize(request)
      @request = request
    end
    attr_reader :request

    def auth
      request.env["omniauth.auth"]
    end

    #
    # @return User
    #
    def connect
      fail NotImplementedError, "You must implement #{self.class}##{__method__}"
    end
  end
end
