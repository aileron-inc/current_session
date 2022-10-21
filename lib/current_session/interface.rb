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
        session_repository(request).try do |repository|
          repository.find { |user| self.current_user = user }
        end
        self
      end

      def create(request)
        auth = @auth_class.new(request)
        auth.call do |user|
          auth.update(user)
          session_repository(request).update_session_token(user)
        end
      end

      def destroy(request)
        self.current_user = nil
        session_repository(request).try do |repository|
          repository.destroy
          repository.delete_session_token
        end
      end

      private

      def session_repository(request)
        @session_class.new(
          request: request,
          user_class: user_class,
          session_token_class: session_token_class,
          current_time: current_time(request)
        )
      end
    end
  end
end
