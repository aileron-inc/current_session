# frozen_string_literal: true

module CurrentSession
  #
  # Base class for implementing current_user
  #
  class Base < ActiveSupport::CurrentAttributes
    include CurrentSession::Interface
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

      def session_methods=(session_methods)
        @session_methods = session_methods
        @session_class = CurrentSession::SessionMethod.new_session_class(session_methods)
      end

      def session_methods(&block)
        if block
          @session_methods = Module.new(&block)
          @session_class = CurrentSession::SessionMethod.new_session_class(session_methods)
        else
          @session_methods
        end
      end

      def auth_methods=(auth_methods_module)
        @auth_class = CurrentSession::AuthMethod.new_auth_class(auth_methods_module)
      end

      def auth_methods(&block)
        if block
          @auth_methods = Module.new(&block)
          @auth_class = CurrentSession::AuthMethod.new_auth_class(auth_methods)
          @auth_class.user_class = user_class
        else
          @auth_methods
        end
      end
    end
  end
end
