# frozen_string_literal: true

require_relative "current_session/version"
require "active_support"

module CurrentSession
  extend ActiveSupport::Autoload
  autoload :Base
  autoload :Interface
  autoload :Auth
  autoload :Repository
  autoload :RaiseNotImplementedError

  autoload :UidSession
  autoload :EnvSession
  autoload :ActiveRecordSession

  def self.key(user_class)
    "session_#{user_class.name.underscore.parameterize(separator: "_")}_key"
  end
end
