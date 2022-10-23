# frozen_string_literal: true

module CurrentSession
  #
  # Base class for providing auth methods
  #
  class AuthMethod
    class_attribute :user_class

    # only exist users
    class FindBy < self
      def call(&block)
        find_by_auth.try(&block)
      end
    end

    # admit new users
    class FindOrCreateBy < self
      def call(&block)
        find_or_create_by_auth.try(&block)
      end
    end

    def self.new_auth_class(auth_methods_module)
      new_auth_class =
        if auth_methods_module.method_defined?(:find_by_auth)
          Class.new(CurrentSession::AuthMethod::FindBy) { include auth_methods_module }
        elsif auth_methods_module.method_defined?(:find_or_create_by_auth)
          Class.new(CurrentSession::AuthMethod::FindOrCreateBy) { include auth_methods_module }
        else
          fail NotImplementedError, "You must implement find_by_auth or find_or_create_by_auth"
        end
      new_auth_class.user_class = user_class
      new_auth_class
    end

    def initialize(request)
      @request = request
    end
    attr_reader :request

    def auth
      request.env["omniauth.auth"]
    end
  end
end
