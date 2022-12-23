# frozen_string_literal: true

module CurrentSession
  #
  # configuration dsl
  #
  module Dsl
    extend ActiveSupport::Concern
    class_methods do
      def session_methods=(session_method)
        @session_methods = CurrentSession::SessionMethod.new_class(session_method)
      end

      def session_methods(&block)
        if block
          @session_methods = CurrentSession::SessionMethod.new_class(Module.new(&block))
        else
          @session_methods
        end
      end

      def auth_methods=(auth_method)
        @auth_methods = CurrentSession::AuthMethod.new_class(auth_method)
      end

      def auth_methods(&block)
        if block
          @auth_methods = CurrentSession::AuthMethod.new_class(Module.new(&block))
        else
          @auth_methods
        end
      end
    end
  end
end
