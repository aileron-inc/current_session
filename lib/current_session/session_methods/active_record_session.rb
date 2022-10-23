# frozen_string_literal: true

module CurrentSession
  module SessionMethods
    #
    # Implementation of session tokens for DB management
    #
    module ActiveRecordSession
      def find
        session_token_class.find_by(value: session_token).try do |record|
          update(record)
          yield record.user
        end
      end

      def create(user)
        session_token_class.create(user_id: user.id, value: new_session_token) do |record|
          update(record)
          yield record.value
        end
      end

      def destroy
        session_token_class.find_by(value: session_token)&.destroy
      end

      private

      def update(token)
        token.update(
          last_request_at: current_time,
          last_request_ip: request.remote_ip,
          last_request_user_agent: request.user_agent
        )
      end
    end
  end
end
