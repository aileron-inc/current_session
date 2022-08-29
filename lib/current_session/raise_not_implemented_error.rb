# frozen_string_literal: true

module CurrentSession
  #
  # Class for verifying whether it is implemented correctly
  #
  module RaiseNotImplementedError
    extend ActiveSupport::Concern
    class_methods do
      def raise_not_implemented_error
        raise_not_implemented_error_for_repository
        raise_not_implemented_error_for_auth
      end

      private

      # rubocop:disable Layout/LineLength
      def raise_not_implemented_error_for_repository
        raise NotImplementedError, "You must setting self.session_repository_class= or session_methods" unless @session_repository_class
        raise NotImplementedError, "You must implement #{@session_repository_class}#find" unless @session_repository_class.method_defined? :find
        raise NotImplementedError, "You must implement #{@session_repository_class}#destroy" unless @session_repository_class.method_defined? :destroy
        raise NotImplementedError, "You must implement #{@session_repository_class}#destroy" unless @session_repository_class.method_defined? :destroy
        raise NotImplementedError, "You must implement #{@session_repository_class}#create" unless @session_repository_class.method_defined? :create
      end
      # rubocop:enable Layout/LineLength

      # rubocop:disable Layout/LineLength
      def raise_not_implemented_error_for_auth
        raise NotImplementedError, "You must setting self.auth_class= or auth_methods" unless @auth_class
        raise NotImplementedError, "You must implement #{@auth_class}#find_or_create_by_auth" unless @auth_class.method_defined? :find_or_create_by_auth
        raise NotImplementedError, "You must implement #{@auth_class}#update" unless @auth_class.method_defined? :update
      end
      # rubocop:enable Layout/LineLength
    end
  end
end
