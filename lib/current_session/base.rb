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
      attr_accessor :session_token_class
      attr_reader :user_class

      def user_class=(user_class)
        @user_class = user_class
        @auth_class.user_class = user_class if @auth_class
      end

      def current_time(_)
        Time.current
      end

      def session_methods=(session_methods_module)
        @session_repository_class = Class.new(CurrentSession::Repository) { include session_methods_module }
      end

      def session_methods(&block)
        if block
          session_methods = Module.new(&block)
          @session_repository_class = Class.new(CurrentSession::Repository) { include session_methods }
          @session_methods = session_methods
        else
          @session_methods
        end
      end

      def auth_methods=(auth_methods_module)
        @auth_class = Class.new(CurrentSession::Auth) { include auth_methods_module }
      end

      def auth_methods(&block)
        if block
          auth_methods = Module.new(&block)
          @auth_class = Class.new(CurrentSession::Auth) { include auth_methods }
          @auth_class.user_class = user_class
          @auth_methods = auth_methods
        else
          @auth_methods
        end
      end
    end
  end
end
