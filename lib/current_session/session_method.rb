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

    def key
      @key ||= CurrentSession.key(user_class)
    end

    def session_token
      @session_token ||= request.session[key]
    end

    def new_session_token
      SecureRandom.urlsafe_base64(64)
    end

    def delete_session_token
      request.session.delete(key)
    end

    def update_session_token(user)
      request.session[key] = create(user)
    end

    def try
      session_token.presence.try do |_|
        yield self
      end
    end
  end
end
