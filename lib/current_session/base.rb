# frozen_string_literal: true

module CurrentSession
  #
  # Base class for implementing current_user
  #
  class Base < ActiveSupport::CurrentAttributes
    include CurrentSession::Interface
    include CurrentSession::RaiseNotImplementedError
    attribute :current_user

    class << self
      attr_accessor :user_class, :session_token_class

      def current_time(_)
        Time.current
      end

      def session_methods=(session_methods_module)
        @session_repository_class = Class.new(CurrentSession::Repository) { include session_methods_module }
      end

      def session_methods(&block)
        session_methods = Module.new(&block)
        const_set(:SessionMethods, session_methods)
        @session_repository_class = Class.new(CurrentSession::Repository) { include session_methods }
      end

      def auth_methods=(auth_methods_module)
        @auth_class = Class.new(CurrentSession::Auth) { include auth_methods_module }
      end

      def auth_methods(&block)
        auth_methods = Module.new(&block)
        const_set(:AuthMethods, auth_methods)
        @auth_class = Class.new(CurrentSession::Auth) { include auth_methods }
      end
    end
  end
end
