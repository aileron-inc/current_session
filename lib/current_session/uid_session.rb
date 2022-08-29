# frozen_string_literal: true

module CurrentSession
  #
  # Implementation of using UIDs as session tokens
  #
  class UidSession < Repository
    def find(&block)
      user_class.find_by(uid: session_token).try(&block)
    end

    def create(user)
      user.uid
    end

    def destroy
    end
  end
end
