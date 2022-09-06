# frozen_string_literal: true

module CurrentSession
  module SessionMethods
    #
    # Implementation of using UIDs as session tokens
    #
    module UidSession
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
end
