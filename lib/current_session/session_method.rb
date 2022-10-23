# frozen_string_literal: true

module CurrentSession
  #
  # Base class for processing to get session_token from request.session
  #
  class SessionMethod
    def self.new_session_class(session_methods)
      Class.new(CurrentSession::SessionMethod) { include session_methods }
    end

    def initialize(current_time:, request:, user_class:, session_token_class:)
      @current_time = current_time
      @request = request
      @user_class = user_class
      @session_token_class = session_token_class
    end
    attr_reader :current_time, :request, :user_class, :session_token_class

    def find_by_token(&block)
      try_session_token { find(&block) }
    end

    def delete_session_token
      try_session_token do
        request.session.delete(key)
        destroy
      end
    end

    def update_session_token(user)
      create(user) { |value| request.session[key] = value }
    end

    protected

    def try_session_token
      session_token.presence.try do
        yield self
      end
    end

    def find
      fail NotImplementedError, "You must implement #{self.class}##{__method__}"
    end

    def create(user, &block)
      fail NotImplementedError, "You must implement #{self.class}##{__method__}"
    end

    def destroy
      fail NotImplementedError, "You must implement #{self.class}##{__method__}"
    end

    def key
      @key ||= CurrentSession.key(user_class)
    end

    def session_token
      @session_token ||= request.session[key]
    end

    def new_session_token
      SecureRandom.urlsafe_base64(64)
    end
  end
end
