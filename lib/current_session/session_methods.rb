# frozen_string_literal: true

#
# Reference implementation of session_methods
#
module CurrentSession
  module SessionMethods
    autoload :UidSession
    autoload :EnvSession
    autoload :ActiveRecordSession
  end
end
