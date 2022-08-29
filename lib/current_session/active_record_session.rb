# frozen_string_literal: true

module CurrentSession
  #
  # Implementation of session tokens for DB management
  #
  class ActiveRecordSession < Repository
    def find
      session_token_class.find_by(value: session_token).try do |record|
        update(record)
        yield record.user
      end
    end

    def create(user)
      session_token_class.create(user_id: user.id, value: new_session_token) do |record|
        update(record)
      end.value
    end

    def update(token)
      token.update(
        last_request_at: current_time,
        last_request_ip: request.remote_ip,
        last_request_user_agent: request.user_agent
      )
    end

    def destroy
      session_token_class.find_by(value: session_token)&.destroy
    end
  end
end
