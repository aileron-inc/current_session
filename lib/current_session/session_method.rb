# frozen_string_literal: true

module CurrentSession
  #
  # session Method
  #
  class SessionMethod
    def self.new_class(methods)
      Class.new(self) do
        include methods
      end
    end

    def self.define(&block)
      Module.new do
        define_method(:find, &block)
        define_method(:create) {}
        define_method(:destroy) {}
      end
    end

    def initialize(request)
      @request = request
    end
    attr_reader :request

    #
    # @return User
    #
    def find
      fail NotImplementedError, "You must implement #{self.class}##{__method__}"
    end

    def create(user)
      fail NotImplementedError, "You must implement #{self.class}##{__method__}"
    end

    def destroy
      fail NotImplementedError, "You must implement #{self.class}##{__method__}"
    end

    def new_session_token
      SecureRandom.urlsafe_base64(128)
    end
  end
end
