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

      def session_repository_class=(session_repository_class = nil)
        @session_repository_class = session_repository_class
      end

      def session_methods(&block)
        @session_repository_class = Class.new(CurrentSession::Repository, &block)
      end

      def auth_methods(&block)
        @auth_class = Class.new(CurrentSession::Auth, &block)
      end
    end
  end
end
