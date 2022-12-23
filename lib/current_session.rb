# frozen_string_literal: true

require_relative "current_session/version"
require "active_support"

#
# current_session
#
module CurrentSession
  extend ActiveSupport::Autoload
  autoload :Base
  autoload :Dsl
  autoload :Interface
  autoload :AuthMethod
  autoload :SessionMethod

  def self.key(namespace)
    "session_#{namespace.name.underscore.parameterize(separator: "_")}_key"
  end
end
