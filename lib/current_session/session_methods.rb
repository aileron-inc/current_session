# frozen_string_literal: true

#
# Reference implementation of session_methods
#
module CurrentSession
  module SessionMethods
    extend ActiveSupport::Autoload
    autoload :UidSession
    autoload :EnvSession
    autoload :ActiveRecordSession
  end
end
