# frozen_string_literal: true

module CurrentSession
  #
  # Interface for manipulating http request objects
  #
  module Interface
    extend ActiveSupport::Concern
    class_methods do
      def call(request)
        update(request).current_user.present?
      end

      def update(request)
        self.current_user = @session_methods.new(request).find
        self
      end

      def create(request)
        self.current_user = @auth_methods.new(request).connect
        @session_methods.new(request).create(current_user)
        self
      end

      def destroy(request)
        @session_methods.new(request).destroy
      end
    end
  end
end
